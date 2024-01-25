import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/login/const/data.dart';
import 'package:mamasteps_frontend/login/const/login_platform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  LoginPlatform _loginPlatform = LoginPlatform.none;
  final dio = Dio();

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      // try {
      //   final resp = await dio.post(
      //     '서버 주소',
      //     options: Options(
      //       headers: {
      //         'email': googleUser.email,
      //         'id': googleUser.id,
      //         'serverauthcode' : googleUser.serverAuthCode,
      //       },
      //     ),
      //   );
      //   storage.write(key: 'ACCESS_TOKEN', value: resp.data['access_token']);
      //   storage.write(key: 'REFRESH_TOKEN', value: resp.data['refresh_token']);
      // } catch (e) {
      //   print(e);
      // }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );

      setState(() {
        _loginPlatform = LoginPlatform.google;
      });
    }
  }

  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      default:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loginPlatform != LoginPlatform.none
            ? _logoutButton()
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loginButton('google_logo', signInWithGoogle),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return Card(
      elevation: 5.0,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: AssetImage('asset/image/$path.png'),
        width: 60,
        height: 60,
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(35.0),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('로그아웃'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color(0xff0165E1),
        ),
      ),
    );
  }
}
