import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final user_storage = new FlutterSecureStorage();

Future<void> setUser(String key, String value) async {
  await user_storage.write(key: key, value: value);
}

Future<String?> getUser(String key) async {
  return await user_storage.read(key: key);
}