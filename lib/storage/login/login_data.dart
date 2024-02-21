import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/calendar/v3.dart';

const ACCESS_TOKEN_KEY = '';
const REFRESH_TOKEN_KEY = '';

final storage = FlutterSecureStorage();

void deleteAll() async {
  await storage.deleteAll();
}