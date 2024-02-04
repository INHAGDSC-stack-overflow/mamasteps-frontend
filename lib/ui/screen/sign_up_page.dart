import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';
import 'package:mamasteps_frontend/ui/layout/default_layout.dart';
import 'package:numberpicker/numberpicker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _dateController = TextEditingController();
  DateTime date = DateTime.now();
  List<String> userInformation = ['', '', '', '',];
  DateTime? selectedDate;
  PageController _pageController = PageController(initialPage: 0);
  int user_activity_hours = 0;
  int user_activity_minutes = 0;
  List<List<bool>> scheduleData = List.generate(
    24, // 24시간
    (i) => List.generate(7, (j) => false), // 각 요일에 대한 데이터
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    content: contents[3],
                    onHoursChanged: onActivitesHourChanged,
                    onMinutesChanged: onActivitesMinuteChanged,
                    hour: user_activity_hours,
                    minute: user_activity_minutes,
                  ),
                  _scheduleSubPage(
                    // 산책 선호 시간 입력 페이지
                    content: contents[5],
                    scheduleData: scheduleData,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Expanded(
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
                    OutlinedButton(onPressed: (){
                      print("이름 : $userInformation");
                      print("나이 : $userInformation");
                      print("임신 날짜 : $userInformation");
                      print("활동량 : $user_activity_hours 시간 $user_activity_minutes 분");
                      print("산책 선호 시간 : $scheduleData");
                    }, child: Text('출력'))
                  ],
                ),
              ),
            ),
          ],
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

  void onActivitesHourChanged(value) {
    setState(() {
      user_activity_hours = value;
    });
  }

  void onActivitesMinuteChanged(value) {
    setState(() {
      user_activity_minutes = value;
    });
  }

  void onNumberChanged(value) {
    setState(() {
      userInformation[5] = value;
    });
  }

  void onChangeSchedule(int hour, int day) {
    setState(() {
      scheduleData[hour][day] = !scheduleData[hour][day];
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

class _subPage extends StatelessWidget {
  final ValueChanged onChanged;
  final String content;

  const _subPage({
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

class _subPage1 extends StatelessWidget {
  final ValueChanged onChanged;

  const _subPage1({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(contents[0]),
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
  final _dateController = TextEditingController();
  DateTime date = DateTime.now();
  DateTime? _selectedDate;
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
  final ValueChanged onHoursChanged;
  final ValueChanged onMinutesChanged;
  final int hour;
  final int minute;
  final String content;
  const _activitiesSubPage({
    super.key,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.hour,
    required this.minute,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumberPicker(
                value: widget.hour,
                minValue: 0,
                maxValue: 23,
                onChanged: widget.onHoursChanged,
              ),
              Text("시간"),
              NumberPicker(
                value: widget.minute,
                minValue: 0,
                maxValue: 59,
                onChanged: widget.onMinutesChanged,
              ),
              Text("분"),
            ],
          ),
        ),
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
  void onChangeSchedule(int hour, int day) {
    setState(() {
      widget.scheduleData[hour][day] = !widget.scheduleData[hour][day];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(contents[4]),
        SingleChildScrollView(
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
                        onChangeSchedule(hour, day);
                      },
                      child: Container(
                        color: widget.scheduleData[hour][day]
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
      ],
    );
  }
}
