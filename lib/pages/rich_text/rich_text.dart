import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import '../../fonts_loader/fonts_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as ImageProcess;

final FontsLoader loader = FontsLoader();

class MyRichText extends StatefulWidget {
  MyRichText({super.key}) {
    loader.loadFonts();
  }

  @override
  State<MyRichText> createState() => _MyRichTextState();
}

class _MyRichTextState extends State<MyRichText> {
  bool firstEntry = false;
  final PDFPageFormat params = PDFPageFormat.a4;
  final QuillController _quillController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0));
  final FocusNode _editorNode = FocusNode();
  final ValueNotifier<bool> _shouldShowToolbar = ValueNotifier<bool>(false);
  final Map<String, String> cachedImages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Text'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onPressed: () {
            context.pop();
          },
        ),
       ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _quillController,
            configurations: QuillSimpleToolbarConfigurations(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
            ),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _quillController,
              configurations: QuillEditorConfigurations(
                embedBuilders: [
                  ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfigurations: QuillEditorImageEmbedConfigurations(
                        shouldRemoveImageCallback: (imageUrl) async {
                          cachedImages.remove(imageUrl);
                          return true;
                        },
                        imageProviderBuilder: (context, imageUrl) {
                          // If the image is local (base64 doesn't contain :// or a Blob), we use our custom ImageProvider
                          if (!imageUrl.contains("://") || imageUrl.contains("blob")) {
                            return Base64ImageProvider(value: imageUrl, cache: cachedImages);
                          } else {
                            // To avoid CORS restriction for Flutter Web (Canvaskit) dealing with images with go through a proxy
                            return NetworkImage("https://corsproxy.io/?$imageUrl");
                          }
                        }
                      ),

                    ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed:  () async {
              var isGranted = await Permission.storage.request().isGranted;
              if (!isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                      Text('无权限')
                  ),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) {
                  return const LoadingWithAnimtedWidget(
                    text: 'Creating document...',
                    infinite: true,
                    loadingColor: Color.fromARGB(255, 108, 189, 255),
                  );
                });
              final String? result =
                  await FilePicker.platform.getDirectoryPath();
              if (result == null) {
                Navigator.pop(context);
                return;
              }
              File file = File('$result/document_demo_quill_to_pdf.pdf');
              PDFConverter pdfConverter = PDFConverter(
                backMatterDelta: null,
                frontMatterDelta: null,
                document: _quillController.document.toDelta(),
                fallbacks: [...loader.allFonts()],
                onRequestBoldFont: (String fontFamily) async {
                  return loader.getFontByName(
                      fontFamily: fontFamily, bold: true);
                },
                onRequestBoldItalicFont: (String fontFamily) async {
                  return loader.getFontByName(
                      fontFamily: fontFamily, bold: true, italic: true);
                },
                onRequestFallbackFont: (String fontFamily) async {
                  return null;
                },
                onRequestItalicFont: (String fontFamily) async {
                  return loader.getFontByName(
                      fontFamily: fontFamily, italic: true);
                },
                onRequestFont: (String fontFamily) async {
                  return loader.getFontByName(fontFamily: fontFamily);
                },
                pageFormat: params,
              );
              final pw.Document? document =
                  await pdfConverter.createDocument();
              if (document == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'The file cannot be generated by an unknown error')),
                );
                _editorNode.unfocus();
                _shouldShowToolbar.value = false;
                Navigator.pop(context);
                return;
              }
              await file.writeAsBytes(await document.save());
              _editorNode.unfocus();
              _shouldShowToolbar.value = false;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Generated document at path: ${file.path}')),
              );
            },
            child: Text('Export PDF'),
          ),
        ],
      )
    );
  }


  @override
  void dispose() {
    _quillController.dispose();
    _editorNode.dispose();
    _shouldShowToolbar.dispose();
    super.dispose();
  }
}

class Base64ImageProvider extends ImageProvider<Base64ImageProvider> {
  final String value; // Used to uniquely identify the image. Can be the blob URL or the base64 value
  final Map<String, String> cache;

  Base64ImageProvider({required this.value, required this.cache});

  @override
  Future<Base64ImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Base64ImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(Base64ImageProvider key, ImageDecoderCallback decode) {
    // Use `decode` to process the image bytes
    return OneFrameImageStreamCompleter(_loadAsync(decode));
  }

  // The async function that decodes the image bytes into an ImageInfo
  Future<ImageInfo> _loadAsync(ImageDecoderCallback decode) async {
    // Convert the base64 string into Uint8List (image bytes)
    Uint8List imageBytes = base64Decode(await getBase64());

    // Convert the image bytes to an ImmutableBuffer
    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(imageBytes);

    // Decode the ImmutableBuffer into a Codec
    final codec = await decode(buffer);

    // Get the first frame from the Codec
    final frame = await codec.getNextFrame();

    // Return the image as ImageInfo
    return ImageInfo(image: frame.image, scale: 1.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Base64ImageProvider typedOther = other as Base64ImageProvider;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  Future<String> getBase64() async {
    if (value.contains("://") && !value.contains("blob")) {
      // it's already a base64 representation
      return value;
    }

    // value is a url like blob:http://etc.
    if (cache.containsKey(value)) {
      return SynchronousFuture(cache[value]!);
    }

    File file = File(value);
    final imageFile = ImageProcess.decodeImage(
      file.readAsBytesSync(),
    );
    if (imageFile != null) {
      // Convert ByteData to Uint8List
      Uint8List byteData = ImageProcess.encodePng(imageFile);

      // Encode the Uint8List (image bytes) to base64
      cache[value] = base64Encode(byteData);
      return cache[value]!;
    } else {
      throw Exception('Failed to convert image to ByteData');
    }
  }
}
class LoadingWithAnimtedWidget extends StatelessWidget {
  final String text;
  final double verticalTextPadding;
  final double? heightWidget;
  final double? spaceBetween;
  final double strokeWidth;
  final TextStyle? style;
  final Duration duration;
  final Color? loadingColor;
  final bool infinite;
  const LoadingWithAnimtedWidget({
    super.key,
    required this.text,
    this.loadingColor,
    this.strokeWidth = 7,
    this.spaceBetween,
    this.duration = const Duration(milliseconds: 260),
    this.infinite = false,
    this.style,
    this.heightWidget,
    this.verticalTextPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: false,
      child: Dialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: heightWidget ?? size.height * 0.45,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  color: loadingColor,
                ),
                SizedBox(height: spaceBetween ?? 10),
                AnimatedWavyText(
                  infinite: infinite,
                  duration: duration,
                  text: text,
                  style: style ??
                      const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                  verticalPadding: verticalTextPadding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedWavyText extends StatelessWidget {
  final double verticalPadding;
  final Key? animatedKey;
  final String text;
  final bool infinite;
  final int totalRepeatCount;
  final Duration duration;
  final TextStyle? style;
  const AnimatedWavyText({
    super.key,
    this.animatedKey,
    this.verticalPadding = 50,
    required this.text,
    this.infinite = false,
    this.totalRepeatCount = 4,
    this.duration = const Duration(milliseconds: 260),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: AnimatedTextKit(
        key: animatedKey,
        repeatForever: infinite,
        animatedTexts: <AnimatedText>[
          WavyAnimatedText(
            text,
            speed: duration,
            textStyle: style ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
        displayFullTextOnTap: true,
        totalRepeatCount: totalRepeatCount < 1 ? 1 : totalRepeatCount,
      ),
    );
  }
}