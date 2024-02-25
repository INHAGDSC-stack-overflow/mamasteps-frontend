import 'dart:convert';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';

Future<void> addRecord(int completedTimeSeconds) async {
  const url = 'https://dev.mamasteps.dev/api/v1/calendar/addRecord';
  final AccessToken = await storage.read(key: 'access_token');
  DateTime date = DateTime.now();
  String isoDate = date.toIso8601String();

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'id': 0,
        'routeId': 0,
        'date': isoDate,
        'completedTimeSeconds': completedTimeSeconds,
        'createdAt': isoDate,
        'updatedAt': isoDate,
      }),
    );

    print('addRecord Server Response: ${response.statusCode}');
    print('addRecord Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('addRecord success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      // return apiResponse;
    } else {
      print('addRecord server error');
    }
  } catch (error) {
    print(error);
  }
}

Future<void> addSchedule(DateTime date, int targetTimeSeconds, int id) async {
  const url = 'https://dev.mamasteps.dev/api/v1/calendar/addSchedule';
  final AccessToken = await storage.read(key: 'access_token');
  String isoDate = date.toIso8601String();

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'routeId': id,
        'date': isoDate,
        'targetTimeSeconds': targetTimeSeconds,
        'createdAt': isoDate,
        'updatedAt': isoDate,
      }),
    );

    print('addSchedule Server Response: ${response.statusCode}');
    print('addSchedule Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('addSchedule Server success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      // return apiResponse;
    } else {
      print('addSchedule Server error');
    }
  } catch (error) {
    print(error);
  }
}


Future<void> createAutoSchedule() async {
  const url = 'https://dev.mamasteps.dev/api/v1/calendar/createAutoSchedule';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('createAutoSchedule Server Response: ${response.statusCode}');
    print('createAutoSchedule Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('createAutoSchedule : success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);

    } else {
      return Future.error('createAutoSchedule server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<getScheduleResponse> getSchedule() async {
  const url = 'https://dev.mamasteps.dev/api/v1/calendar/getSchedules';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('getSchedule Server Response: ${response.statusCode}');
    print('getSchedule Server Response: ${response.body}');

    if (response.statusCode == 200) {
      print('getSchedule success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final getScheduleResponse apiResponse =
      getScheduleResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      return Future.error('getSchedule server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<getRecordResponse> getRecords() async {
  const url = 'https://dev.mamasteps.dev/api/v1/calendar/getRecords';
  final AccessToken = await storage.read(key: 'access_token');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $AccessToken',
      },
    );

    print('getRecords Server Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('getRecords success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final getRecordResponse apiResponse =
      getRecordResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      return Future.error('getRecords server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}
