import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/ui/layout/sign_up_default_layout.dart';
import 'package:mamasteps_frontend/ui/screen/home_screen.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';
import 'package:mamasteps_frontend/ui/screen/sign_up_page.dart';
import 'package:mamasteps_frontend/ui/screen/splash_screen.dart';

void main() async {
  runApp(
    GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        // 2번코드
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}
