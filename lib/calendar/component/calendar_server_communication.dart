import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';

Future<void> addRecord(int completedTimeSeconds) async {
  final url = 'https://dev.mamasteps.dev/api/v1/calendar/addRecord';
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

    print('Server Response: ${response.statusCode}');
    print('Exception: ${response.body}');

    if (response.statusCode == 200) {
      print('success');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
      // return apiResponse;
    } else {
      print('server error');
    }
  } catch (error) {
    print(error);
  }
}

Future<void> createAutoSchedule() async {
  final url = 'https://dev.mamasteps.dev/api/v1/calendar/createAutoSchedule';
  final AccessToken = await storage.read(key: 'access_token');

  try {
    final response = await http.post(
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

    } else {
      return Future.error('server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<getScheduleResponse> getSchdule() async {
  final url = 'https://dev.mamasteps.dev/api/v1/calendar/getSchedules';
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
      final getScheduleResponse apiResponse =
      getScheduleResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      return Future.error('server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}

Future<getRecordResponse> getRecords() async {
  final url = 'https://dev.mamasteps.dev/api/v1/calendar/getRecords';
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
      final getRecordResponse apiResponse =
      getRecordResponse.fromJson(jsonResponse);
      return apiResponse;
    } else {
      return Future.error('server error');
    }
  } catch (error) {
    return Future.error(error);
  }
}
