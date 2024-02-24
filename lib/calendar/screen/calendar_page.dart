import 'package:flutter/material.dart';

import 'package:googleapis/calendar/v3.dart' as calendarv3;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mamasteps_frontend/calendar/component/google_calendar.dart' as myGoogleCalendar;

class Event {
  int id;
  int? routeId;
  String title;
  DateTime date;
  int totalTime;
  Event(this.id, this.routeId, this.title, this.date, this.totalTime);
}

class TableCalendarPage extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final ValueNotifier<List<Event>> selectedEvents;
  final List<Event> Function(DateTime) getEventsForDay;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final VoidCallback acceptResponse;
  final VoidCallback initSetting;
  final VoidCallback onFABTap;

  const TableCalendarPage({super.key,
    required this.events,
    required this.selectedEvents,
    required this.getEventsForDay,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.acceptResponse,
    required this.initSetting,
    required this.onFABTap,
  });

  @override
  State<TableCalendarPage> createState() => _TableCalendarPageState();
}

class _TableCalendarPageState extends State<TableCalendarPage> {
  // late calendarv3.CalendarApi calendar;
  // late calendarv3.Calendar primaryCalendar;
  // final Map<DateTime, List<Event>> events = {
  //   DateTime.utc(2024, 2, 1): [Event('13 분', DateTime.utc(2024, 2, 1,15,20))],
  //   DateTime.utc(2024, 2, 3): [Event('13 분', DateTime.utc(2024, 2, 3,15,20))],
  //   DateTime.utc(2024, 2, 15): [Event('17 분', DateTime.utc(2024, 2, 15,13,15))],
  //   DateTime.utc(2024, 2, 11): [Event('23 분', DateTime.utc(2024, 2, 11,17,15))],
  //   DateTime.utc(2024, 2, 20): [Event('23 분', DateTime.utc(2024, 2, 20,17,15))],
  //   DateTime.utc(2024, 1, 14): [Event('20 분', DateTime.utc(2024, 1, 14,13,40))],
  //   DateTime.utc(2024, 2, 5): [Event('13 분', DateTime.utc(2024, 2, 5,15,20))],
  //   DateTime.utc(2024, 2, 8): [Event('13 분', DateTime.utc(2024, 2, 8,15,20))],
  //   DateTime.utc(2024, 2, 21): [Event('13 분', DateTime.utc(2024, 2, 21,15,20))],
  // };
  //
  // DateTime selectedDay = DateTime(
  //   DateTime.now().year,
  //   DateTime.now().month,
  //   DateTime.now().day,
  // );
  //
  // DateTime focusedDay = DateTime.now();
  //
  // late ValueNotifier<List<Event>> selectedEvents;

  @override
  void initState() {
    super.initState();
    // selectedEvents = ValueNotifier(_getEventsForDay(selectedDay));
    //initGoogleCalendar();
    // googleInit();
    //widget.initSetting();
  }

  // @override
  // void dispose() {
  //   widget.selectedEvents.dispose();
  //   super.dispose();
  // }

  // void googleInit() async{
  //   await myGoogleSignIn.signInSilently();
  //   final auth.AuthClient? client = await myGoogleSignIn.authenticatedClient();
  //   assert(client != null, 'Authenticated client missing!');
  //   final calendarv3.CalendarApi calendarApi = calendarv3.CalendarApi(client!);
  //   setState(() {
  //     calendar = calendarApi;
  //   });
  // }

  // void initGoogleCalendar() async {
  //   calendar = await initCalendarApi();
  //   primaryCalendar = await getCalendar(calendar, 'primary');
  //   await getEvent(calendar);
  //   calendarv3.Event myEvent = calendarv3.Event(end: calendarv3.EventDateTime(date: DateTime.now()), start: calendarv3.EventDateTime(), description: 'test');
  //   await insertEvent(calendar, myEvent);
  // }
  // void acceptResponse() async {
  //   getScheduleResponse apiResponse = await getSchdule();
  //   if (apiResponse.isSuccess) {
  //     setState(() {
  //       for (int i = 0; i < apiResponse.result.length; i++) {
  //         DateTime date = apiResponse.result[i].date;
  //         int completedTimeSeconds = apiResponse.result[i].targetTimeSeconds;
  //         int hours = completedTimeSeconds ~/ 3600;
  //         int minutes = (completedTimeSeconds % 3600) ~/ 60;
  //         String hourTime = '${hours.toString().padLeft(2, '0')} 시';
  //         String time =
  //             '${minutes.toString().padLeft(2, '0')} 분';
  //
  //         DateTime endTime = apiResponse.result[i].date.add(Duration(seconds: completedTimeSeconds));
  //
  //         var tempEvent = calendarv3.Event(
  //             summary: "${time} 산책 일정",
  //             start: calendarv3.EventDateTime(
  //               dateTime: date,
  //             ),
  //             end: calendarv3.EventDateTime(
  //               dateTime: endTime,
  //             ));
  //
  //         myGoogle.insertEvents(calendar,tempEvent);
  //
  //         DateTime eventDate = DateTime.utc(date.year, date.month, date.day);
  //         // if (events[eventDate] != null) {
  //         //   // 해당날짜에 이벤트가 이미 있는 경우
  //         //   events[eventDate]!.add(Event(time, apiResponse.result[i].date));
  //         // } else {
  //         // 해당날짜에 이벤트가 없는 경우
  //         events[eventDate] = [Event(time, apiResponse.result[i].date)];
  //         //}
  //       }
  //     });
  //   }
  // }

  // List<Event> _getEventsForDay(DateTime day) {
  //   return events[day] ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              // _showSelectDialog();
              widget.onFABTap();
            }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      child: Image.asset(
                        'asset/image/others_home_screen_back_ground_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "산책 일정 관리",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Card(
                        child: TableCalendar(
                          // 캘린더
                          locale: 'ko_KR',
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: widget.focusedDay,
                          onDaySelected: widget.onDaySelected,
                          selectedDayPredicate: (DateTime day) {
                            return isSameDay(widget.selectedDay, day);
                          },
                          eventLoader: widget.getEventsForDay,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        //날짜 출력부
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateFormat('yyyy년 MM월 dd일 산책일정').format(widget.selectedDay),
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        // 이벤트 리스트 출력부
                        child: ValueListenableBuilder<List<Event>>(
                          valueListenable: widget.selectedEvents,
                          builder: (context, value, _) {
                            return ListView.builder(
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                print(value[index].date.hour);
                                String formatTime;
                                if(value[index].date.hour > 12){
                                  formatTime = "오후 ${value[index].date.hour % 12}시";
                                }
                                else if(value[index].date.hour==12){
                                  formatTime = "오후 12시";
                                }
                                else{
                                  formatTime = "오전 ${value[index].date.hour}시";
                                }
                                return ListTile(
                                  title: SizedBox(
                                    height: 80,
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Align(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${formatTime} ${value[index].date.minute.toString().padLeft(2,'0')}분",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  value[index].title,
                                                  style: TextStyle(
                                                    color: Color(0xffa412db),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.centerLeft),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




