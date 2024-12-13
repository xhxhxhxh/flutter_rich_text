import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyRichText extends StatelessWidget {
  const MyRichText({super.key});

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
            context.go('/');
          },
        ),
       ),
      body: Center()
    );
  }
}