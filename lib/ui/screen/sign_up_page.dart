import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';
import 'package:mamasteps_frontend/ui/layout/root_tab_default_layout.dart';
import 'package:numberpicker/numberpicker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
    7, // 7일
    (i) => List.generate(24, (j) => false), // 각 요일에 대한 데이터
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    _nameSubPage(
                      // 이름 입력 페이지
                      content: contents[0],
                      onChanged: onNameChanged,
                    ),
                    _ageSubPage(
                      // 나이 입력 페이지
                      content: contents[1],
                      onChanged: onAgeChanged,
                    ),
                    _dateSubPage(
                      // 임신 날짜 입력 페이지
                      content: contents[2],
                      dateController: _dateController,
                      onTap:
                          onDateChanged(selectedDate, context, _dateController),
                    ),
                    _activitiesSubPage(
                      // 활동량 입력 페이지
                      onhighChanged: onHighActivitesChanged,
                      onmiddleChanged: onMiddleActivitesChanged,
                      onlowChanged: onLowActivitesChanged,
                      content: contents[3],
                    ),
                    _scheduleSubPage(
                      // 산책 선호 시간 입력 페이지
                      content: contents[4],
                      scheduleData: scheduleData,
                    ),
                    _onNumberSubPage(
                      // 보호자 전화번호 입력 페이지
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
                    OutlinedButton(
                      onPressed: onPrevPressed,
                      child: Text('이전'),
                    ),
                    OutlinedButton(
                      onPressed: onNextPressed,
                      child: Text('다음'),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          print("이름 : " + userInformation[0].toString());
                          print("나이 : " + userInformation[1].toString());
                          print("임신 날짜 :" + selectedDate.toString());
                          print("활동량 : " + userInformation[2].toString());
                          print("월 산책 선호 시간 : " + scheduleData[0].toString());
                          print("화 산책 선호 시간 : " + scheduleData[1].toString());
                          print("수 산책 선호 시간 : " + scheduleData[2].toString());
                          print("목 산책 선호 시간 : " + scheduleData[3].toString());
                          print("금 산책 선호 시간 : " + scheduleData[4].toString());
                          print("토 산책 선호 시간 : " + scheduleData[5].toString());
                          print("일 산책 선호 시간 : " + scheduleData[6].toString());
                          print("보호자 전화번호 : " + userInformation[3].toString());
                        },
                        child: Text('출력'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(content),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(content),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.content),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: widget.dateController,
          readOnly: true,
          onTap: widget.onTap,
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
        Text(widget.content),
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
        Text(widget.content),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(content),
        const SizedBox(height: 16.0),
        TextFormField(
          autofocus: true,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
