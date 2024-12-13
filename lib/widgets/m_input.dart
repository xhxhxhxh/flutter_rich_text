import 'package:flutter/material.dart';

class MInput extends StatelessWidget {
  final double? height;
  final double? width;
  final double fontSize;
  final Color? backgroundColor;
  final Color textColor;
  final BorderRadius? borderRadius;
  final String? text;
  final Function? cb;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final Function? tap;
  final TextEditingController? controller;
  MInput({
    this.height,
    this.width = double.infinity,
    this.fontSize = 30,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderRadius,
    this.text,
    this.obscureText = false,
    this.cb,
    this.tap,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.controller
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        onTap: () => {
          if (tap != null) {
            tap!()
          }
        },
        enabled: enabled,
        maxLines: maxLines,
        autofocus: false,
        style: TextStyle(color: textColor),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          hintStyle: TextStyle(
              color: textColor
          ),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: backgroundColor,
          labelText: text,
        ),
        onChanged: (value){
          if (cb != null) {
            cb!(value);
          }
        },
      ),
        
    );
  }
}
