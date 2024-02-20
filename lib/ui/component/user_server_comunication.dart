import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';

Future<getMeResponse> getMe() async {
  final url = 'https://dev.mamasteps.dev/api/v1/users/me';
  final AccessToken = await storage.read(key: 'access_token');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('Server Response: ${response.statusCode}');
    print('Exception: ${response.body}');

    if (response.statusCode == 200) {
      print('success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final getMeResponse apiResponse =
      getMeResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      return Future.error('server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

// Future<DateTime> getMe() async {
//   final url = 'https://dev.mamasteps.dev/api/v1/users/me';
//   final AccessToken = await storage.read(key: 'access_token');
//   try {
//     final response = await http.get(
//       Uri.parse(url),
//       headers: <String, String>{
//         'Authorization': 'Bearer $AccessToken',
//       },
//     );
//
//     print('Server Response: ${response.statusCode}');
//     print('Exception: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print('success');
//       final jsonResponse = jsonDecode(response.body);
//       print(jsonResponse);
//       final getMeResponse apiResponse =
//       getMeResponse.fromJson(jsonResponse);
//       return apiResponse.result.pregnancyStartDate;
//     } else {
//       return Future.error('server error');
//     }
//   } catch (error) {
//     return Future.error(error);
//   }
// }