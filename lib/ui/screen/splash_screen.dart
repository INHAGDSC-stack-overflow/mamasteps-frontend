import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/ui/screen/home_screen.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => debugcheck());
  }

  void debugcheck() async {
    storage.deleteAll();
    String? accessToken = await storage.read(key: 'access_token');
    if(accessToken==null){// 토큰이 없는 경우
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => GoogleLogin(),
        ),
            (route) => false,
      );
    }
    else {// 토큰이 있는 경우
      print(myGoogleSignIn.currentUser);
      myGoogleSignIn.signInSilently();
      print(myGoogleSignIn.currentUser);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RootTab(),
        ),
            (route) => false,
      );
    }
  }

  //
  // void deleteToken() async {
  //   await storage.deleteAll();
  // }
  //
  // void checkToken() async {
  //
  //   final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
  //   final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
  //
  //   //토큰의 유효성까지 검사 하는 코드, http 패키지로 수정부탁드려요
  //   try {
  //     final resp = await dio.post(
  //       'http://$ip/auth/token',// token 검사 api 주소
  //       options: Options(
  //         headers: {'authorization': 'Bearer $refreshToken'},
  //       ),
  //     );
  //     // accessToken으로 refresh토큰을 갱신하는 코드
  //     await storage.write(key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);
  //     // 로그인 성공 시 화면 전환
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(
  //         builder: (_) => RootTab(),
  //       ),
  //           (route) => false,
  //     );
  //   } catch (e) { // 토큰이 없거나 만료된 경우
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(
  //         builder: (_) => GoogleLogin(),
  //       ),
  //           (route) => false,
  //     );
  //   }
  //
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.abc, size: 100, color: Colors.white),
            CircularProgressIndicator(),
          ],
        ),
      )
    );
  }
}
