import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';

// void makeRequest() async {
//   final url = 'https://dev.mamasteps.dev/api/v1/routes/computeRoutes';
//   final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);
//
//   List<Coordinate> redMarker = convertMarkersToList(startClosewayPoints);
//   List<Coordinate> blueMarker = convertMarkersToList(endClosewayPoints);
//
//   clientToServerTimeConvert();
//
//   var requestData = RequestData(
//       targetTime: totalSec,
//       origin: Coordinate(
//           latitude: currentPosition.latitude,
//           longitude: currentPosition.longitude),
//       startCloseIntermediates: redMarker,
//       endCloseIntermediates: blueMarker);
//
//   Map<String, dynamic> jsonData = requestData.toJson();
//   String jsonString = jsonEncode(jsonData);
//
//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $AccessToken',
//       },
//       body: jsonString,
//     );
//
//     print('Server Response: ${response.statusCode}');
//     print('Exception: ${response.body}');
//
//     if (response.statusCode == 200) {
//       acceptResponse(response.body);
//     } else {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) => GoogleLogin(),
//         ),
//         (route) => false,
//       );
//       print('Server Error');
//     }
//   } catch (error) {
//     print('Server Error');
//   }
// }

void makeRequest(Function(String) callBack, BuildContext context) async {
  final url = 'https://dev.mamasteps.dev/api/v1/routes/getRoutes';
  final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);

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
      callBack(response.body);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleLogin(),
        ),
        (route) => false,
      );
    }
  } catch (error) {
    print(error);
  }
}
