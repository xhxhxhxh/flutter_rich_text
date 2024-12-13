import 'package:flutter/material.dart';
import '../../widgets/m_input.dart';


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
    final theme = Theme.of(context);  

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset('images/user.png', fit: BoxFit.cover),
            ),
            SizedBox(height: 40),
            MInput(
              controller:_controller,
              height: 90,
              width: 200,
              backgroundColor: theme.colorScheme.primary,
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

              } : null,
              child: Text('Button'),
            ),
          ],
        ),
      ),
    );
  }
}