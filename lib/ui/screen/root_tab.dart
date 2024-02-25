import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendarv3;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:mamasteps_frontend/calendar/screen/calendar_page.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/storage/user/user_data.dart';
import 'package:mamasteps_frontend/ui/component/user_server_comunication.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';
import 'package:mamasteps_frontend/ui/screen/home_screen.dart';
import 'package:mamasteps_frontend/ui/screen/user_profile_page.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'dart:collection';

class RootTab extends StatefulWidget {
  // final GoogleSignIn? myGoogleSignIn;
  final VoidCallback? acceptGetInfo;
  const RootTab({
    super.key,
    this.acceptGetInfo,
    // this.myGoogleSignIn,
  });

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  //유저 정보 관련
  late getMeResponse getMeApiResponse = getMeResponse(
      isSuccess: false,
      code: "code",
      message: "message",
      pregnancyStartDate: [0, 0, 0, 0, 0],
      guardianPhoneNumber: "0",
      result: UserProfile(
          profileImageUrl: "profileImageUrl",
          email: "email",
          name: "name",
          age: 0,
          pregnancyStartDate: DateTime.now(),
          guardianPhoneNumber: "0",
          activityLevel: "low",
          walkPreferences: []));

  //탭바 컨트롤 관련
  late TabController controller;
  int index = 0;

  //Schedule
  //0.
  late GoogleSignInAccount? _currentUser;
  //1. 전체 스케쥴 리스트(key(DateTime), value(event.date)를 기준으로 정렬됨)
  final Map<DateTime, List<Event>> events =
      SplayTreeMap<DateTime, List<Event>>();

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
  // void googleInit() async {
  // if(_currentUser == null){
  //   _currentUser = await myGoogleSignIn.signIn();
  // }
  // final auth.AuthClient? client = await myGoogleSignIn.authenticatedClient();
  // assert(client != null, 'Authenticated client missing!');
  // if (client != null) {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (_) => GoogleLogin()),
  //     (route) => false,
  //   );
  // }
  // final calendarv3.CalendarApi calendarApi = calendarv3.CalendarApi(client!);
  // //acceptResponse(calendarApi);
  // }

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
    //_currentUser = await myGoogleSignIn.signIn();
    //var tempEvent = calendarv3.Event();
    DateTime usersFirstScheduleDate =
        DateTime.now().subtract(Duration(days: 240));
    DateTime usersLastScheduleDate = DateTime.now().add(Duration(days: 240));
    //await myGoogleSignIn.signInSilently();
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
    getScheduleResponse apiResponse = await getSchedule(); //로컬 스케쥴 목록이 추가되는 곳
    if (apiResponse.isSuccess) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime todayZeroHour = DateTime(now.year, now.month, now.day);
        DateTime startOfWeek =
            todayZeroHour.subtract(Duration(days: now.weekday - 1));
        print("일주일의 시작" + startOfWeek.toString());
        DateTime endOfWeek = todayZeroHour
            .add(Duration(days: DateTime.daysPerWeek - now.weekday + 1));
        print("일주일의 끝" + endOfWeek.toString());
        for (int i = 0; i < apiResponse.result.length; i++) {
          DateTime apiDate = apiResponse.result[i].date;
          // 이번주 총 산책 시간 계산

          DateTime date = apiResponse.result[i].date;
          print(date.toString());
          int id = apiResponse.result[i].id;
          int? routeId = apiResponse.result[i].routeId;
          int completedTimeSeconds = apiResponse.result[i].targetTimeSeconds;
          int minutes = (completedTimeSeconds % 3600) ~/ 60;
          String time = '${minutes.toString().padLeft(2, '0')} 분';

          // DateTime endTime = apiResponse.result[i].date
          //     .add(Duration(seconds: completedTimeSeconds));

          var localTempEvent =
              Event(id, routeId, time, date, completedTimeSeconds);

          DateTime eventDate = DateTime.utc(date.year, date.month, date.day);
          bool isDuplicate = events[eventDate]?.any(
                  (existingEvent) => // 유저가 매뉴얼로 입력하는 코드에서 변경해야 할 부분
                      existingEvent.date.year == localTempEvent.date.year &&
                      existingEvent.date.month == localTempEvent.date.month &&
                      existingEvent.date.day == localTempEvent.date.day) ??
              false;
          if (!isDuplicate) {
            print("삽입되는 로컬 스케쥴 : " +
                localTempEvent.title +
                localTempEvent.date.toString());
            events.putIfAbsent(eventDate, () => []).add(localTempEvent);
            if (localTempEvent.date.isAfter(startOfWeek) &&
                localTempEvent.date.isBefore(endOfWeek)) {
              // 이번주에 산책 일정이 몇개인지
              totalWeekAchievement++;
              print(
                  "totalWeekAchievement : " + totalWeekAchievement.toString());
            }
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
        if (totalWeekAchievement == 0) {
          totalWeekAchievement = 1;
        }
        events.forEach((key, value) {
          value.sort((a, b) => a.date.compareTo(b.date));
        });
        if (events.isNotEmpty) {
          usersFirstScheduleDate = events.keys.first;
          usersLastScheduleDate = events.keys.last.add(Duration(days: 1));
          print("userFirstScheduleDate :" + usersFirstScheduleDate.toString());
          print("userLastScheduleDate :" + usersLastScheduleDate.toString());
        }
        print("events length: ${events.length}");
      });

      try {
        googleEvents = await calendarApi.events.list(
          //구글 스케쥴 리스트가 들어오는 곳
          'primary',
          timeMin: usersFirstScheduleDate,
          timeMax: usersLastScheduleDate,
          maxResults: 10000,
          singleEvents: true,
          orderBy: 'startTime',
        );

        if (googleEvents.items == null) {
          print('구글 이벤트 리스트가 비어있음');
          for (DateTime date in events.keys) {
            List<Event> dayEvents = events[date]!;
            for (Event localElement in dayEvents) {
              var summary =
                  "${(localElement.totalTime ~/ 60).toString().padLeft(2, '0')}분 산책일정";
              var start = localElement.date;
              var end = localElement.date
                  .add(Duration(seconds: localElement.totalTime));
              var tempEvent = calendarv3.Event(
                summary: summary,
                start: calendarv3.EventDateTime(dateTime: start),
                end: calendarv3.EventDateTime(dateTime: end),
                reminders:
                    calendarv3.EventReminders(useDefault: false, overrides: [
                  calendarv3.EventReminder(method: 'popup', minutes: 0),
                ]),
              );
              //print("${summary} ${start} ${end} ${tempEvent}");
              // Google 캘린더의 이벤트와 비교 로직 (for 루프 사용)
              // 이벤트 추가 로직
              await calendarApi.events.insert(tempEvent, 'primary');
              //print("새 이벤트 추가: ${summary} ${start} ${end}");
            }
          }
        } else {
          for (DateTime date in events.keys) {
            List<Event> dayEvents = events[date]!;
            for (Event localElement in dayEvents) {
              bool isExist = false;
              var summary =
                  "${(localElement.totalTime ~/ 60).toString().padLeft(2, '0')}분 산책일정";
              var start = localElement.date;
              var end = localElement.date
                  .add(Duration(seconds: localElement.totalTime));
              var tempEvent = calendarv3.Event(
                summary: summary,
                start: calendarv3.EventDateTime(dateTime: start),
                end: calendarv3.EventDateTime(dateTime: end),
                reminders:
                    calendarv3.EventReminders(useDefault: false, overrides: [
                  calendarv3.EventReminder(method: 'popup', minutes: 0),
                ]),
              );
              //print("${summary} ${start} ${end} ${tempEvent}");
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
                await calendarApi.events.insert(tempEvent, 'primary');
                //print("새 이벤트 추가: ${summary} ${start} ${end}");
              }
            }
          }
          //googleEvents.items?.forEach((e) => print("구글 이벤트 리스트 :${e.start?.dateTime?.toIso8601String()} : ${e.summary}"));
        }
      } catch (e) {
        // API 호출 실패나 다른 예외 발생 시 출력
        print('API 호출 중 오류 발생: $e');
      }
    }
  }

  void userManualAdd() async {
    //_currentUser = await myGoogleSignIn.signIn();
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
    getScheduleResponse apiResponse = await getSchedule(); //로컬 스케쥴 목록이 추가되는 곳
    if (apiResponse.isSuccess) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime todayZeroHour = DateTime(now.year, now.month, now.day);
        DateTime startOfWeek =
            todayZeroHour.subtract(Duration(days: now.weekday - 1));
        print("일주일의 시작" + startOfWeek.toString());
        DateTime endOfWeek = todayZeroHour
            .add(Duration(days: DateTime.daysPerWeek - now.weekday + 1));
        print("일주일의 끝" + endOfWeek.toString());
        for (int i = 0; i < apiResponse.result.length; i++) {
          DateTime apiDate = apiResponse.result[i].date;
          // 이번주 총 산책 시간 계산

          DateTime date = apiResponse.result[i].date;
          print(date.toString());
          int id = apiResponse.result[i].id;
          int? routeId = apiResponse.result[i].routeId;
          int completedTimeSeconds = apiResponse.result[i].targetTimeSeconds;
          int minutes = (completedTimeSeconds % 3600) ~/ 60;
          String time = '${minutes.toString().padLeft(2, '0')} 분';

          // DateTime endTime = apiResponse.result[i].date
          //     .add(Duration(seconds: completedTimeSeconds));

          var localTempEvent =
              Event(id, routeId, time, date, completedTimeSeconds);

          DateTime eventDate = DateTime.utc(date.year, date.month, date.day);
          bool isDuplicate = events[eventDate]?.any(
                  (existingEvent) => // 유저가 매뉴얼로 입력하는 코드에서 변경해야 할 부분
                      existingEvent.date.year == localTempEvent.date.year &&
                      existingEvent.date.month == localTempEvent.date.month &&
                      existingEvent.date.day == localTempEvent.date.day) ??
              false;
          if (!isDuplicate) {
            print("삽입되는 로컬 스케쥴 : " +
                localTempEvent.title +
                localTempEvent.date.toString());
            events.putIfAbsent(eventDate, () => []).add(localTempEvent);
            if (localTempEvent.date.isAfter(startOfWeek) &&
                localTempEvent.date.isBefore(endOfWeek)) {
              // 이번주에 산책 일정이 몇개인지
              totalWeekAchievement++;
              print(
                  "totalWeekAchievement : " + totalWeekAchievement.toString());
            }
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
        if (totalWeekAchievement == 0) {
          totalWeekAchievement = 1;
        }
        events.forEach((key, value) {
          value.sort((a, b) => a.date.compareTo(b.date));
        });
        if (events.isNotEmpty) {
          usersFirstScheduleDate = events.keys.first;
          usersLastScheduleDate = events.keys.last.add(Duration(days: 1));
          print("userFirstScheduleDate :" + usersFirstScheduleDate.toString());
          print("userLastScheduleDate :" + usersLastScheduleDate.toString());
        }
        print("events length: ${events.length}");
      });

      try {
        googleEvents = await calendarApi.events.list(
          //구글 스케쥴 리스트가 들어오는 곳
          'primary',
          timeMin: usersFirstScheduleDate,
          timeMax: usersLastScheduleDate,
          maxResults: 10000,
          singleEvents: true,
          orderBy: 'startTime',
        );

        if (googleEvents.items == null) {
          print('구글 이벤트 리스트가 비어있음');
          for (DateTime date in events.keys) {
            List<Event> dayEvents = events[date]!;
            for (Event localElement in dayEvents) {
              var summary =
                  "${(localElement.totalTime ~/ 60).toString().padLeft(2, '0')}분 산책일정";
              var start = localElement.date;
              var end = localElement.date
                  .add(Duration(seconds: localElement.totalTime));
              var tempEvent = calendarv3.Event(
                summary: summary,
                start: calendarv3.EventDateTime(dateTime: start),
                end: calendarv3.EventDateTime(dateTime: end),
                reminders:
                    calendarv3.EventReminders(useDefault: false, overrides: [
                  calendarv3.EventReminder(method: 'popup', minutes: 0),
                ]),
              );
              //print("${summary} ${start} ${end} ${tempEvent}");
              // Google 캘린더의 이벤트와 비교 로직 (for 루프 사용)
              // 이벤트 추가 로직
              await calendarApi.events.insert(tempEvent, 'primary');
              //print("새 이벤트 추가: ${summary} ${start} ${end}");
            }
          }
        } else {
          for (DateTime date in events.keys) {
            List<Event> dayEvents = events[date]!;
            for (Event localElement in dayEvents) {
              bool isExist = false;
              var summary =
                  "${(localElement.totalTime ~/ 60).toString().padLeft(2, '0')}분 산책일정";
              var start = localElement.date;
              var end = localElement.date
                  .add(Duration(seconds: localElement.totalTime));
              var tempEvent = calendarv3.Event(
                summary: summary,
                start: calendarv3.EventDateTime(dateTime: start),
                end: calendarv3.EventDateTime(dateTime: end),
                reminders:
                    calendarv3.EventReminders(useDefault: false, overrides: [
                  calendarv3.EventReminder(method: 'popup', minutes: 0),
                ]),
              );
              //print("${summary} ${start} ${end} ${tempEvent}");
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
                await calendarApi.events.insert(tempEvent, 'primary');
                //print("새 이벤트 추가: ${summary} ${start} ${end}");
              }
            }
          }
          //googleEvents.items?.forEach((e) => print("구글 이벤트 리스트 :${e.start?.dateTime?.toIso8601String()} : ${e.summary}"));
        }
      } catch (e) {
        // API 호출 실패나 다른 예외 발생 시 출력
        print('API 호출 중 오류 발생: $e');
      }
    }
  }

  //Record
  late int weeks = 0;
  late int todayWalkTimeTotalSeconds = 0;
  // late int todayWalkTimeMin = 0;
  late int thisWeekWalkTimeTotalSeconds = 0;
  late int recommended = 0;
  // late int thisWeekWalkTimeHour = 0;
  // late int thisWeekWalkTimeMin = 0;
  late int thisWeekAchievement = 0;
  late int totalWeekAchievement;
  late List<int> weekWalkTime = [0, 0, 0, 0, 0, 0, 0];

  void pageInit() {
    weeks = 0;
    todayWalkTimeTotalSeconds = 0;
    thisWeekWalkTimeTotalSeconds = 0;
    recommended = 0;
    thisWeekAchievement = 0;
    totalWeekAchievement = 0;
    weekWalkTime = [0, 0, 0, 0, 0, 0, 0];
  }

  // void initThisWeekAchievement() {
  //   setState(() {
  //     for (int i = 0; i < weekWalkTime.length; i++) {
  //       if (weekWalkTime[i] > recommended * 0.9) {
  //         thisWeekAchievement++;
  //       }
  //     }
  //   });
  // }

  void acceptGetInfo() async {
    myInfo apiResponse = await getMyInfo(context);
    setState(() {
      if (apiResponse.isSuccess) {
        recommended = apiResponse.targetTime ~/ 60;
      }
    });
  }

  void acceptUserResponse() async {
    getMeResponse apiResponse = await getMe();
    setState(() {
      getMeApiResponse = apiResponse;
      print(getMeApiResponse.code);
      DateTime now = DateTime.now();
      Duration difference = now.difference(DateTime(
          apiResponse.pregnancyStartDate[0],
          apiResponse.pregnancyStartDate[1],
          apiResponse.pregnancyStartDate[2]));
      weeks = difference.inDays ~/ 7;
      // if (apiResponse.isSuccess) {
      //   weeks = weeks;
      // }
      user_storage.write(
          key: 'guardianPhoneNumber', value: apiResponse.guardianPhoneNumber);
    });
  }

  void acceptGetRecords() async {
    getRecordResponse apiResponse = await getRecords();
    setState(
      () {
        if (apiResponse.isSuccess) {
          DateTime now = DateTime.now();
          DateTime todayZeroHour = DateTime(now.year, now.month, now.day);
          DateTime startOfWeek =
              todayZeroHour.subtract(Duration(days: now.weekday - 1));
          print("일주일의 시작" + startOfWeek.toString());
          DateTime endOfWeek = todayZeroHour
              .add(Duration(days: DateTime.daysPerWeek - now.weekday + 1));
          for (int i = 0; i < apiResponse.result.length; i++) {
            DateTime apiDate = apiResponse.result[i].date;
            int apiCompletedTimeSeconds =
                apiResponse.result[i].completedTimeSeconds.toInt() ~/ 60;
            int difference = apiDate.difference(startOfWeek).inDays;
            // 이번주 총 산책 시간 계산
            if (apiResponse.result[i].date.isAfter(startOfWeek) &&
                apiResponse.result[i].date.isBefore(endOfWeek)) {
              // 요일별 시간 저장
              weekWalkTime[difference] += apiCompletedTimeSeconds;
              thisWeekWalkTimeTotalSeconds +=
                  apiResponse.result[i].completedTimeSeconds;
              // 이번주에 몇 번 산책했는지
            }
            // 오늘 산책 시간 계산
            isSameDate(apiDate, now)
                ? todayWalkTimeTotalSeconds +=
                    apiResponse.result[i].completedTimeSeconds
                : null;
          }
          for (int i = 0; i < 7; i++) {
            if (weekWalkTime[i] > 0) {
              thisWeekAchievement++;
              print("이번주 산책 횟수 : " + thisWeekAchievement.toString());
            }
          }
          // for (int i = 0; i < weekWalkTime.length; i++) {
          //   if (weekWalkTime[i] > recommended * 0.9) {
          //     thisWeekAchievement++;
          //   }
          // }
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    //await myGoogleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    //googleInit();

    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
    selectedEvents = ValueNotifier(getEventsForDay(selectedDay));
    pageInit();
    // if(myGoogleSignIn.currentUser==null) {
    //   loginSilently();
    // }
    initSchedule();
    //acceptResponse();
    acceptUserResponse();
    acceptGetRecords();
    acceptGetInfo();
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
                      child: HomeScreen(
                        weeks: weeks,
                        todayWalkTimeTotalSeconds: todayWalkTimeTotalSeconds,
                        thisWeekWalkTimeTotalSeconds:
                            thisWeekWalkTimeTotalSeconds,
                        recommended: recommended,
                        thisWeekAchievement: thisWeekAchievement,
                        totalWeekAchievement: totalWeekAchievement,
                        weekWalkTime: weekWalkTime,
                      ),
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
                        acceptResponse: acceptResponse,
                        initSetting: initSchedule,
                        onFABTap: showSelectDialog,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: userProfilePage(
                        imageUrl: getMeApiResponse.result.profileImageUrl,
                        userEmail: getMeApiResponse.result.email,
                        name: getMeApiResponse.result.name,
                        age: getMeApiResponse.result.age,
                        pregnancyStartDate:
                            getMeApiResponse.result.pregnancyStartDate,
                        guardianPhoneNumber:
                            getMeApiResponse.result.guardianPhoneNumber,
                        activityLevel: getMeApiResponse.result.activityLevel,
                        walkPreferences:
                            getMeApiResponse.result.walkPreferences,
                      ),
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

  void showSelectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이벤트 추가'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                acceptResponse();
              });
              Navigator.of(context).pop();
            },
            child: Text('자동 추가 하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showAddDialog();
            },
            child: Text('직접 입력 하기'),
          ),
        ],
      ),
    );
  }

  void showAddDialog() {
    final TextEditingController _timeController = TextEditingController();
    final TextEditingController _miniuteController = TextEditingController();
    final TextEditingController _walkTimeController = TextEditingController();
    var _hour = 0, _min = 0, _time = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: Container(
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: "산책 시작 시간을 입력해 주세요 (시)",
                  labelText: "산책 시작 시간 (시)",
                ),
                controller: _timeController,
                onChanged: (value) {
                  _timeController.text = value;
                  _hour = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "산책 시작 시간을 입력해 주세요 (분)",
                  labelText: "산책 시작 시간 (분)",
                ),
                controller: _miniuteController,
                onChanged: (value) {
                  _miniuteController.text = value;
                  _min = int.parse(value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "산책 시간을 입력해 주세요 (분)",
                  labelText: "산책 시간",
                ),
                controller: _walkTimeController,
                onChanged: (value) {
                  _walkTimeController.text = value;
                  _time = int.parse(value);
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              var now = DateTime.now();
              var id = now.year + now.month * 12 + now.day * 30;
              var dateTime = DateTime(selectedDay.year, selectedDay.month,
                  selectedDay.day, _hour, _min);
              var targetTimeSeconds = _time * 60;
              await addSchedule(dateTime, targetTimeSeconds, id);
              setState(() {
                initSchedule();
              });
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // void _showEditDialog(index) {
  //   final TextEditingController _eventController = TextEditingController();
  //   _eventController.text = events[selectedDay]![index].title;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Edit Event'),
  //       content: TextField(
  //         controller: _eventController,
  //         decoration: InputDecoration(hintText: 'Event Name'),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (_eventController.text.isEmpty) return;
  //             setState(() {
  //               events[selectedDay]![index].title = _eventController.text;
  //             });
  //             _eventController.clear();
  //             Navigator.of(context).pop();
  //           },
  //           child: Text('Save'),
  //         ),
  //         TextButton(
  //           child: Text('delete'),
  //           onPressed: () {
  //             setState(
  //                   () {
  //                 events[selectedDay]!.removeAt(index);
  //               },
  //             );
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
  //print("${eventA.title}과 ${eventB.summary}의 비교");
  var UtcDateAStart = eventA.date;
  var UtcDateAEnd = UtcDateAStart.add(Duration(seconds: eventA.totalTime));
  var UtcDateBStart = eventB.start?.dateTime?.toLocal();
  var UtcDateBEnd = eventB.end?.dateTime?.toLocal();
  //print("UtcDate start and End : ${UtcDateAStart}, ${UtcDateAEnd}, ${UtcDateBStart}, ${UtcDateBEnd}, ${eventB.summary}");
  return (isSameTime(UtcDateAStart, UtcDateBStart) &&
      isSameTime(UtcDateAEnd, UtcDateBEnd));
}

bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
