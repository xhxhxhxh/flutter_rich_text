import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/rich_text/rich_text.dart';
import '../../widgets/m_input.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var username = '';
  final TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    var isButtonEnabled = username.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset('assets/images/user.png', fit: BoxFit.cover),
            ),
            SizedBox(height: 40),
            MInput(
              controller:_controller,
              height: 90,
              width: 200,
              backgroundColor: Colors.white,
              textColor: Color(0xFF737373),
              text: '姓名',
              cb: (val) => {
                setState(() {
                  username = val;
                })
              }
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isButtonEnabled ? () => {
                // context.go('/richText')
                context.push('/richText')
              } : null,
              child: Text('Go'),
            ),
          ],
        ),
      ),
    );
  }
}