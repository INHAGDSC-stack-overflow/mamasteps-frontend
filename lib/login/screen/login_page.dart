import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:mamasteps_frontend/login/const/login_platform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';
import 'package:mamasteps_frontend/ui/screen/sign_up_page.dart';
import 'package:mamasteps_frontend/ui/screen/splash_screen.dart';


final GoogleSignIn myGoogleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '[YOUR_OAUTH_2_CLIENT_ID]',
  scopes: <String>[CalendarApi.calendarScope],
);

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  void signInWithGoogle() async {
    // deleteAll();
    // await GoogleSignIn().signOut();
    final GoogleSignInAccount? googleUser = await myGoogleSignIn.signIn();


    // 로그인

    if (googleUser != null) {
      print('name = ${googleUser.email}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.displayName}');
      print('photoUrl = ${googleUser.photoUrl}');

      final url = 'https://dev.mamasteps.dev/api/v1/auth/google-login';

      final Map<String, dynamic> requestData = {
        "email": "${googleUser.email}",
        "name": "${googleUser.email}",
        "id": "${googleUser.displayName}",
      };

      print(requestData);

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestData),
        );

        print('Server Response: ${response.statusCode}');
        print('Exception: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          String accessToken = data['result']['access_token'];
          await storage.write(key: 'access_token', value: accessToken);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => RootTab(),
              ),
              (route) => false);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpPage(
                    userEmail: googleUser.email,
                    userId: googleUser.id,
                    userName: googleUser.displayName,
                    userPhotoUrl: googleUser.photoUrl,
                ),
              ));
        }
      } catch (error) {
        print('Error sending POST request: $error');
      }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MapPage(),
      //   ),
      // );

      // setState(() {
      //   _loginPlatform = LoginPlatform.google;
      // });
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
      body: Container(
        color: Color(0xffa412db),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/image/mamasteps_logo.png', width: 200,),
              const SizedBox(height: 24),
              _loginButton('continue_with_google', signInWithGoogle),
              const SizedBox(height: 24),
              _loginButton('google_sign_up', signInWithGoogle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton(String path, VoidCallback onTap) {
    return InkWell(
      child: Image.asset('asset/image/$path.png', width: 200),
      onTap: onTap,
    );
  }
}
//   Widget _logoutButton() {
//     return ElevatedButton(
//       onPressed: signOut,
//       child: const Text('로그아웃'),
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(
//           const Color(0xff0165E1),
//         ),
//       ),
//     );
//   }
// }

// Card(
// elevation: 5.0,
// shape: const CircleBorder(),
// clipBehavior: Clip.antiAlias,
// child: Ink.image(
// image: AssetImage('asset/image/$path.png'),
// width: 60,
// height: 60,
// child: InkWell(
// borderRadius: const BorderRadius.all(
// Radius.circular(35.0),
// ),
// onTap: onTap,
// ),
// ),
// );
