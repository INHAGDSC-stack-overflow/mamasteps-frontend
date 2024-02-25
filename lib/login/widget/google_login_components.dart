//
// import 'package:flutter/material.dart';
// import 'package:mamasteps_frontend/login/const/login_platform.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:dio/dio.dart';
// import 'package:mamasteps_frontend/map/screen/map_page.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class GoogleLogin extends StatefulWidget {
//   const GoogleLogin({Key? key}) : super(key: key);
//
//   @override
//   State<GoogleLogin> createState() => _GoogleLoginState();
// }
//
// class _GoogleLoginState extends State<GoogleLogin> {
//   LoginPlatform _loginPlatform = LoginPlatform.none;
//   final dio = Dio();
//
//   void signInWithGoogle() async {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser != null) {
//       print('name = ${googleUser.displayName}');
//       print('email = ${googleUser.email}');
//       print('id = ${googleUser.id}');
//       print('photoUrl = ${googleUser.photoUrl}');
//
//       try {
//         final response = await sendPostRequest(
//           email: googleUser.email,
//           id: googleUser.id,
//           name: googleUser.displayName ?? 'DefaultName',
//         );
//
//         print('Server Response: $response');
//       } catch (error) {
//         print('Error sending POST request: $error');
//       }
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MapPage(),
//         ),
//       );
//
//       setState(() {
//         _loginPlatform = LoginPlatform.google;
//       });
//     }
//   }
//
//   Future<String> sendPostRequest({
//     required String email,
//     required String id,
//     required String name,
//   }) async {
//     final String apiUrl = 'http://3.38.34.206:8080/api/v1/auth/login';
//
//     Map<String, dynamic> requestData = {
//       "email": "hjg000223@gmail.com",
//       "password": "password"
//     };
//
//     String requestBody = json.encode(requestData);
//
//     try {
//       final http.Response response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: requestBody,
//       );
//
//       if (response.statusCode == 200) {
//         return 'POST request successful! Response: ${utf8.decode(response.bodyBytes)}';
//       } else {
//         return 'Failed to send POST request. Status code: ${response.statusCode}\nResponse: ${utf8.decode(response.bodyBytes)}';
//       }
//     } catch (error) {
//       return 'Error sending POST request: $error';
//     }
//   }
//
//   void signOut() async {
//     switch (_loginPlatform) {
//       case LoginPlatform.google:
//         await GoogleSignIn().signOut();
//         break;
//       default:
//         break;
//     }
//
//     setState(() {
//       _loginPlatform = LoginPlatform.none;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _loginPlatform != LoginPlatform.none
//             ? _logoutButton()
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _loginButton('google_logo', signInWithGoogle),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _loginButton(String path, VoidCallback onTap) {
//     return Card(
//       elevation: 5.0,
//       shape: const CircleBorder(),
//       clipBehavior: Clip.antiAlias,
//       child: Ink.image(
//         image: AssetImage('asset/image/$path.png'),
//         width: 60,
//         height: 60,
//         child: InkWell(
//           borderRadius: const BorderRadius.all(
//             Radius.circular(35.0),
//           ),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }
//
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
