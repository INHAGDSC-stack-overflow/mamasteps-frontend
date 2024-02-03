import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/ui/screen/sign_up_page.dart';

void main() async {
  runApp(
    GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CalendarControllerProvider(
        controller: EventController(),
        child: MaterialApp(
          // 2번코드
          debugShowCheckedModeBanner: false,
          home: SignUpPage(),
        ),
      ),
    ),
  );
}
