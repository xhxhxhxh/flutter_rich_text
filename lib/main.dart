import 'package:flutter/material.dart';
import './router/router.dart';
import 'package:english_words/english_words.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}