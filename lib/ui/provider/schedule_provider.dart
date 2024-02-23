// import 'package:flutter/material.dart';
// import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
// import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
//
// import '../../calendar/screen/calendar_page.dart';
//
// class scheduleProvider with ChangeNotifier {
//   final Map<DateTime, List<Event>> events = {};
//
//   Future<Map<DateTime, List<Event>>> getEvents() async {
//     acceptResponse();
//     return events;
//   }
//
//   void acceptResponse() async {
//     getScheduleResponse apiResponse = await getSchedule();
//     if (apiResponse.isSuccess) {
//       for (int i = 0; i < apiResponse.result.length; i++) {
//         DateTime date = apiResponse.result[i].date;
//         print(date.toString());
//         int completedTimeSeconds = apiResponse.result[i].targetTimeSeconds;
//         int hours = completedTimeSeconds ~/ 3600;
//         int minutes = (completedTimeSeconds % 3600) ~/ 60;
//         String hourTime = '${hours.toString().padLeft(2, '0')} 시';
//         String time = '${minutes.toString().padLeft(2, '0')} 분';
//         DateTime eventDate = DateTime.utc(date.year, date.month, date.day);
//         // if (events[eventDate] != null) {
//         //   // 해당날짜에 이벤트가 이미 있는 경우
//         //   events[eventDate]!.add(Event(time, apiResponse.result[i].date));
//         // } else {
//         // 해당날짜에 이벤트가 없는 경우
//         events[eventDate] = [Event(time, date, completedTimeSeconds)];
//         //}
//       }
//     }
//     notifyListeners();
//   }
// }
