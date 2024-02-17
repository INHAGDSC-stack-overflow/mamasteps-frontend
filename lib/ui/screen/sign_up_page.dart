import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';
import 'package:mamasteps_frontend/ui/layout/sign_up_default_layout.dart';
import 'package:mamasteps_frontend/ui/screen/splash_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class SignUpPage extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String? userName;
  final String? userPhotoUrl;

  const SignUpPage({
    super.key,
    required this.userEmail,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int currentPage = 0;
  final _dateController = TextEditingController();
  DateTime date = DateTime.now();
  List<String> userInformation = [
    '',
    '',
    '',
    '',
  ];
  DateTime? selectedDate;
  PageController _pageController = PageController(initialPage: 0);
  List<List<bool>> scheduleData = List.generate(
    7,
    (i) => List.generate(24, (j) => false),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Image.asset(
                    'asset/image/sign_up_back_ground_image.png',
                    fit: BoxFit.fill,
                  )),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: PageView(
                        onPageChanged: onPageChanged,
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [
                          _nameSubPage(
                            content: contents[0],
                            onChanged: onNameChanged,
                          ),
                          _ageSubPage(
                            content: contents[1],
                            onChanged: onAgeChanged,
                          ),
                          _dateSubPage(
                            content: contents[2],
                            dateController: _dateController,
                            onTap: onDateChanged(
                                selectedDate, context, _dateController),
                          ),
                          _activitiesSubPage(
                            onhighChanged: onHighActivitesChanged,
                            onmiddleChanged: onMiddleActivitesChanged,
                            onlowChanged: onLowActivitesChanged,
                            content: contents[3],
                          ),
                          _scheduleSubPage(
                            content: contents[4],
                            scheduleData: scheduleData,
                          ),
                          _onNumberSubPage(
                            content: contents[5],
                            onChanged: onChangeNumber,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed:
                                currentPage > 0 ? onPrevPressed : null,
                            child: Text(
                              '이전',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: currentPage > 0
                                  ? Color(0xffa412db)
                                  : Colors.grey,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: currentPage < 5
                                ? onNextPressed
                                : onSubmitPressed,
                            child: Text(
                              currentPage < 5 ? '다음' : '제출',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: currentPage < 6
                                  ? Color(0xffa412db)
                                  : Colors.grey,
                            ),
                          ),
                          // OutlinedButton(
                          //   onPressed: onSubmitPressed,
                          //   child: Text('출력'),
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void onSubmitPressed() async {
    final url = 'https://dev.mamasteps.dev/api/v1/auth/signup';

    final Map<String, dynamic> requestData = {
      "email": widget.userEmail,
      "name": userInformation[0],
      "age": int.parse(userInformation[1]),
      "pregnancyStartDate": (selectedDate?.toIso8601String() ?? '') + 'Z',
      "guardianPhoneNumber": userInformation[3],
      "profileImage": widget.userPhotoUrl,
      "activityLevel": "HIGH",
      "walkPreferences": convertToWalkPreferencesList(scheduleData)
    };

    print(requestData);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // 성공적인 응답 처리, 예를 들어 새로운 화면으로 이동
        print('Success: ${response.body}');
        Map<String, dynamic> data = jsonDecode(response.body);
        String accessToken = data['result']['accessToken'];
        storage.write(key: 'access_token', value: accessToken);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(),),
          (route) => false,
        );
      } else {
        // 에러 응답 처리
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // 예외 처리
      print('Exception: $e');
    }
  }

  void onNameChanged(value) {
    setState(() {
      userInformation[0] = value;
    });
  }

  void onAgeChanged(value) {
    setState(() {
      userInformation[1] = value;
    });
  }

  GestureTapCallback onDateChanged(
      value, BuildContext context, TextEditingController dataController) {
    return () async {
      await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      ).then((value) {
        if (value != null) {
          setState(() {
            selectedDate = value;
            dataController.text = DateFormat('yyyy-MM-dd').format(value);
          });
        }
      });
    };
  }

  void onHighActivitesChanged() {
    setState(() {
      userInformation[2] = 'HIGH';
    });
  }

  void onMiddleActivitesChanged() {
    setState(() {
      userInformation[2] = 'MIDDLE';
    });
  }

  void onLowActivitesChanged() {
    setState(() {
      userInformation[2] = 'LOW';
    });
  }

  void onChangeSchedule(int hour, int day) {
    setState(() {
      scheduleData[hour][day] = !scheduleData[hour][day];
    });
  }

  void onChangeNumber(value) {
    setState(() {
      userInformation[3] = value;
    });
  }

  void onPrevPressed() {
    setState(() {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  void onNextPressed() {
    setState(() {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }
}

class _nameSubPage extends StatelessWidget {
  final ValueChanged onChanged;
  final String content;
  const _nameSubPage({
    super.key,
    required this.onChanged,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ageSubPage extends StatelessWidget {
  final ValueChanged onChanged;
  final String content;

  const _ageSubPage({
    super.key,
    required this.content,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _dateSubPage extends StatefulWidget {
  final String content;
  final TextEditingController dateController;
  final GestureTapCallback onTap;
  const _dateSubPage(
      {super.key,
      required this.onTap,
      required this.dateController,
      required this.content});

  @override
  State<_dateSubPage> createState() => _dateSubPageState();
}

class _dateSubPageState extends State<_dateSubPage> {
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: widget.dateController,
          readOnly: true,
          onTap: widget.onTap,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _activitiesSubPage extends StatefulWidget {
  final VoidCallback onhighChanged;
  final VoidCallback onmiddleChanged;
  final VoidCallback onlowChanged;
  final String content;
  const _activitiesSubPage({
    super.key,
    required this.onhighChanged,
    required this.onmiddleChanged,
    required this.onlowChanged,
    required this.content,
  });

  @override
  State<_activitiesSubPage> createState() => _activitiesSubPageState();
}

class _activitiesSubPageState extends State<_activitiesSubPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 16.0),
        Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          OutlinedButton(
              onPressed: () {
                widget.onhighChanged();
              },
              child: Text('하루에 30분 이상 가벼운 운동 / 산책'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(
                  width: 2,
                ),
              )),
          OutlinedButton(
              onPressed: () {
                widget.onmiddleChanged();
              },
              child: Text('하루에 20~30분 이상 가벼운 운동 / 산책'),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  side: BorderSide(
                    width: 2,
                  ))),
          OutlinedButton(
              onPressed: () {
                widget.onlowChanged();
              },
              child: Text('하루에 20분 미만 가벼운 운동 / 산책'),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  side: BorderSide(
                    width: 2,
                  ))),
        ])),
      ],
    );
  }
}

class _scheduleSubPage extends StatefulWidget {
  final List<List<bool>> scheduleData;
  final String content;

  const _scheduleSubPage({
    super.key,
    required this.scheduleData,
    required this.content,
  });

  @override
  State<_scheduleSubPage> createState() => _scheduleSubPageState();
}

class _scheduleSubPageState extends State<_scheduleSubPage> {
  void onChangeSchedule(int day, int hour) {
    setState(() {
      widget.scheduleData[day][hour] = !widget.scheduleData[day][hour];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              child: Table(
                // 테이블의 열을 정의합니다. 여기서는 요일을 나타냅니다.
                columnWidths: {
                  0: FixedColumnWidth(50.0), // 시간을 나타내는 첫번째 열
                  1: FlexColumnWidth(), // 나머지 요일 열
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FlexColumnWidth(),
                  6: FlexColumnWidth(),
                  7: FlexColumnWidth(),
                },
                border: TableBorder.all(),
                children: [
                  // 테이블의 행을 정의합니다. 여기서는 각 시간대를 나타냅니다.
                  TableRow(children: [
                    Text('Time'), // 첫 번째 열은 시간을 나타냅니다.
                    Text('Mon'),
                    Text('Tue'),
                    Text('Wed'),
                    Text('Thu'),
                    Text('Fri'),
                    Text('Sat'),
                    Text('Sun'),
                  ]),
                  ...List.generate(24, (hour) {
                    // 24시간을 나타내는 행들을 생성합니다.
                    return TableRow(children: [
                      Text('${hour}:00'), // 시간을 나타내는 첫 번째 셀
                      for (var day = 0; day < 7; day++)
                        InkWell(
                          onTap: () {
                            onChangeSchedule(day, hour);
                          },
                          child: Container(
                            color: widget.scheduleData[day][hour]
                                ? Colors.blue
                                : Colors.transparent,
                            padding: EdgeInsets.all(8),
                            child: Text(''),
                          ),
                        ), // 나머지 셀은 비워둡니다.
                    ]);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _onNumberSubPage extends StatelessWidget {
  final String content;
  final ValueChanged onChanged;
  const _onNumberSubPage({
    super.key,
    required this.content,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

List<Map<String, dynamic>> convertToWalkPreferencesList(
    List<List<bool>> scheduleData) {
  List<Map<String, dynamic>> walkPreferencesList = [];

  for (int day = 0; day < 7; day++) {
    int? startTime;
    int? endTime;

    for (int hour = 0; hour < 24; hour++) {
      if (scheduleData[day][hour]) {
        if (startTime == null) {
          startTime = hour;
        }
      } else {
        if (startTime != null) {
          endTime = hour;
          walkPreferencesList.add({
            'dayOfWeek': getDayOfWeek(day),
            'startTime': startTime,
            'endTime': endTime,
          });
          startTime = null;
          endTime = null;
        }
      }
    }

    if (startTime != null && endTime == null) {
      walkPreferencesList.add({
        'dayOfWeek': getDayOfWeek(day),
        'startTime': startTime,
        'endTime': 24,
      });
    }
  }

  return walkPreferencesList;
}

String getDayOfWeek(int day) {
  List<String> daysOfWeek = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];
  return daysOfWeek[day];
}
