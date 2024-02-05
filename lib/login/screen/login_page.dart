import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.abc, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            InkWell(
              child: Image.asset('asset/image/google_sign_up.png', width: 200),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            InkWell(
              child: Image.asset('asset/image/continue_with_google.png', width: 200),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
