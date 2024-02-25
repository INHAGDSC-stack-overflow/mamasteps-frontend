import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/ui/screen/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart' as localedate;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await localedate.initializeDateFormatting();
  runApp(
    GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: const MaterialApp(
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
