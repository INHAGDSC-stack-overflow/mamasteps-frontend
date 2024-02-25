import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const user_storage = FlutterSecureStorage();

Future<void> setUser(String key, String value) async {
  await user_storage.write(key: key, value: value);
}

Future<String?> getUser(String key) async {
  return await user_storage.read(key: key);
}