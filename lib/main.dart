import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/calendar/component/google_calendar.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/ui/layout/sign_up_default_layout.dart';
import 'package:mamasteps_frontend/ui/screen/home_screen.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';
import 'package:mamasteps_frontend/ui/screen/sign_up_page.dart';
import 'package:mamasteps_frontend/ui/screen/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart' as localedate;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:mamasteps_frontend/ui/provider/schedule_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await localedate.initializeDateFormatting();
  runApp(
    GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        )),
  );
}

// MultiProvider(providers: [
// ChangeNotifierProvider(),
// ]
// GestureDetector(
// onTap: () {
// FocusManager.instance.primaryFocus?.unfocus();
// },
// child: MaterialApp(
// // 2번코드
// debugShowCheckedModeBanner: false,
// home:  SplashScreen(),
// ),
// ),
// ),
