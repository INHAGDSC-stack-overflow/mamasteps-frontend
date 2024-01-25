import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';


void main() async {
  runApp(
    MaterialApp(
         // 2번코드
      debugShowCheckedModeBanner: false,
      home: GoogleLogin(),
    ),
  );
}
