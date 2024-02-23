import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendarv3;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:mamasteps_frontend/calendar/screen/calendar_page.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/ui/screen/home_screen.dart';
import 'package:mamasteps_frontend/ui/screen/user_profile_page.dart';
import 'package:mamasteps_frontend/calendar/component/google_calendar.dart'
    as myGoogleCalendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'dart:collection';

final GoogleSignIn myGoogleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: dotenv.get("myClientId"),
  scopes: <String>[calendarv3.CalendarApi.calendarScope],
);

class RootTab extends StatefulWidget {
  const RootTab({
    super.key,
  });

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  //탭바 컨트롤 관련
  late TabController controller;
  int index = 0;

  //Schedule
  //0.
  GoogleSignInAccount? _currentUser;
  //1. 전체 스케쥴 리스트(key(DateTime), value(event.date)를 기준으로 정렬됨)
  final Map<DateTime, List<Event>> events =
      SplayTreeMap<DateTime, List<Event>>();

  //유저의 첫번째 스케쥴
  //late DateTime usersFirstScheduleDate;
  //유저의 마지막 스케쥴
  //late DateTime usersLastScheduleDate;
  // 특정 기간 내의 검색된 구글 스케쥴의 목록
  late calendarv3.Events googleEvents = calendarv3.Events();
  //2. 선택한 날짜의 스케쥴 리스트
  late ValueNotifier<List<Event>> selectedEvents;
  //3. 선택한 날짜 변경 감지 코드
  // selectedEvents = ValueNotifier(_getEventsForDay(selectedDay));
  //4. 선택한 날짜의 이벤트 반환 함수
  List<Event> getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  //5. 선택한 날짜
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
  //6. 선택한 날짜 변경 함수
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameTime(this.selectedDay, selectedDay)) {
      setState(() {
        this.selectedDay = selectedDay;
        this.focusedDay = focusedDay;
      });
      this.selectedEvents.value = getEventsForDay(selectedDay);
    }
  }

  //7. 구글 캘린더 초기화 함수
  void googleInit() async {
    await myGoogleSignIn.signIn();
    final auth.AuthClient? client = await myGoogleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    if (client != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => GoogleLogin()),
        (route) => false,
      );
    }
    final calendarv3.CalendarApi calendarApi = calendarv3.CalendarApi(client!);
    //acceptResponse(calendarApi);
  }

  //8. + 버튼 클릭시 수행되는 콜백 함수, 자동 일정 추가기능
  void acceptResponse() async {
    await createAutoSchedule();
    initSchedule();
  }

  //11. 종료시 수행되는 함수
  // void dispose() {
  //   selectedEvents.dispose();
  //   super.dispose();
  // }

  //12. 스케쥴
  void initSchedule() async {
    //var tempEvent = calendarv3.Event();
    DateTime usersFirstScheduleDate =
        DateTime.now().subtract(Duration(days: 240));
    DateTime usersLastScheduleDate = DateTime.now().add(Duration(days: 240));
    await myGoogleSignIn.signInSilently();
    final auth.AuthClient? client = await myGoogleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    if (client == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => GoogleLogin()),
        (route) => false,
      );
    }
    final calendarv3.CalendarApi calendarApi = calendarv3.CalendarApi(client!);
    getScheduleResponse apiResponse = await getSchedule();
    if (apiResponse.isSuccess) {
      setState(() {
        for (int i = 0; i < apiResponse.result.length; i++) {
          DateTime date = apiResponse.result[i].date;
          print(date.toString());
          int id= apiResponse.result[i].id;
          int? routeId = apiResponse.result[i].routeId;
          int completedTimeSeconds = apiResponse.result[i].targetTimeSeconds;
          int minutes = (completedTimeSeconds % 3600) ~/ 60;
          String time = '${minutes.toString().padLeft(2, '0')} 분';

          // DateTime endTime = apiResponse.result[i].date
          //     .add(Duration(seconds: completedTimeSeconds));

          var localTempEvent = Event(id, routeId, time, date, completedTimeSeconds);

          DateTime eventDate = DateTime.utc(date.year, date.month, date.day);
          bool isDuplicate = events[eventDate]?.any((existingEvent) =>
                  existingEvent.date.year == localTempEvent.date.year &&
                  existingEvent.date.month == localTempEvent.date.month &&
                  existingEvent.date.day == localTempEvent.date.day) ??
              false;
          if (!isDuplicate) {
            events.putIfAbsent(eventDate, () => []).add(localTempEvent);
          }

          // events[eventDate] = [Event(time, date, completedTimeSeconds)];

          // if (events[eventDate] != null) {
          //   // 해당날짜에 이벤트가 이미 있는 경우
          //   events[eventDate]!.add(Event(time, apiResponse.result[i].date, completedTimeSeconds));
          // } else {
          // //해당날짜에 이벤트가 없는 경우
          // events[eventDate] = [Event(time, date, completedTimeSeconds)];
          // }
        }

        events.forEach((key, value) {
          value.sort((a, b) => a.date.compareTo(b.date));
        });
        if (events.isNotEmpty) {
          usersFirstScheduleDate = events.keys.first;
          usersLastScheduleDate = events.keys.last.add(Duration(days: 1));
          print("userFirstScheduleDate :"+usersFirstScheduleDate.toString());
          print("userLastScheduleDate :" + usersLastScheduleDate.toString());
        }
        print("events length: ${events.length}");
      });

      try {
        googleEvents = await calendarApi.events.list(
          'primary',
          timeMin: usersFirstScheduleDate,
          timeMax: usersLastScheduleDate,
          maxResults: 10000,
          singleEvents: true,
          orderBy: 'startTime',
        );

        if (googleEvents.items == null) {
          print('구글 이벤트 리스트가 비어있음');
        } else {
          for (DateTime date in events.keys) {
            List<Event> dayEvents = events[date]!;
            for (Event localElement in dayEvents) {
              bool isExist = false;
              var summary = "${(localElement.totalTime ~/ 60).toString().padLeft(2,'0')}분 산책일정";
              var start =localElement.date;
              var end = localElement.date.add(Duration(seconds: localElement.totalTime));
              var tempEvent = calendarv3.Event(
                  summary: summary,
                  start: calendarv3.EventDateTime(dateTime: start),
                  end: calendarv3.EventDateTime(dateTime: end)
              );
              print("${summary} ${start} ${end} ${tempEvent}");
              // Google 캘린더의 이벤트와 비교 로직 (for 루프 사용)
              for (var element in googleEvents.items ?? []) {
                if (isSameEvent(localElement, element)) {
                  // 일치하는 이벤트가 있으면 처리
                  isExist = true;
                  break;
                }
              }
              if (!isExist) {
                // 이벤트 추가 로직
                calendarApi.events.insert(tempEvent, 'primary');
                print("새 이벤트 추가: ${summary} ${start} ${end}");
              }
            }
          }
          googleEvents.items?.forEach((e) => print("구글 이벤트 리스트 :${e.start?.dateTime?.toIso8601String()} : ${e.summary}"));
        }
      } catch (e) {
        // API 호출 실패나 다른 예외 발생 시 출력
        print('API 호출 중 오류 발생: $e');
      }
    }
  }

  //Record

  @override
  void initState() {
    super.initState();
    //googleInit();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
    selectedEvents = ValueNotifier(getEventsForDay(selectedDay));
    myGoogleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        print("currentUser : " + _currentUser.toString());
      });
      if (_currentUser != null) {
        //로그인이 되어있는 경우 실행되는 구문
        // _handleGetContact();
      }
    });
    initSchedule();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  // void dispose() {
  //   controller.removeListener(tabListener);
  //   selectedEvents.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('asset/image/root_tab_top_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      child: HomeScreen(),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: TableCalendarPage(
                        events: events,
                        selectedEvents: selectedEvents,
                        getEventsForDay: getEventsForDay,
                        selectedDay: selectedDay,
                        focusedDay: focusedDay,
                        onDaySelected: onDaySelected,
                        googleinit: googleInit,
                        acceptResponse: acceptResponse,
                        initSetting: initSchedule,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: userProfilePage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              controller.animateTo(index);
            },
            currentIndex: index,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.supervised_user_circle_outlined), label: ''),
            ]),
      ),
    );
  }
}

// 시간 비교 함수
bool isSameTime(DateTime? dateA, DateTime? dateB) {
  var UtcDateA = dateA;
  var UtcDateB = dateB;
  return UtcDateA?.year == UtcDateB?.year &&
      UtcDateA?.month == UtcDateB?.month &&
      UtcDateA?.day == UtcDateB?.day &&
      UtcDateA?.hour == UtcDateB?.hour &&
      UtcDateA?.minute == UtcDateB?.minute;
}

//구글 캘린더 이벤트와 로컬 이벤트가 같은 이벤트인지 비교하는 함수 같으면 true 다르면 false를 리턴함
bool isSameEvent(Event eventA, calendarv3.Event eventB) {
  print("${eventA.title}과 ${eventB.summary}의 비교");
  var UtcDateAStart = eventA.date;
  var UtcDateAEnd = UtcDateAStart.add(Duration(seconds: eventA.totalTime));
  var UtcDateBStart = eventB.start?.dateTime?.toLocal();
  var UtcDateBEnd = eventB.end?.dateTime?.toLocal();
  print("UtcDate start and End : ${UtcDateAStart}, ${UtcDateAEnd}, ${UtcDateBStart}, ${UtcDateBEnd}, ${eventB.summary}");
  return (isSameTime(UtcDateAStart, UtcDateBStart) &&
      isSameTime(UtcDateAEnd, UtcDateBEnd));
}
