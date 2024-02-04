import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';
import 'package:numberpicker/numberpicker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  List<String> userInformation = ['', '', '', ''];
  DateTime? selectedDate;
  @override
  PageController _pageController = PageController(initialPage: 0);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
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
                    _subPage0(
                      onChanged: onNameChanged,
                    ),
                    _subPage(
                      content: contents[1],
                      onChanged: onAgeChanged,
                    ),
                    _subPage(
                      content: contents[2],
                      onChanged: onDateChanged,
                    ),
                    _subPage(
                      content: contents[3],
                      onChanged: onActivitesChanged,
                    ),
                    _subpage2(),
                    _subpage3(),
                    _subPage4(
                      onChanged: onNameChanged,
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

  void onDateChanged(value) {
    setState(() {
      userInformation[2] = value;
    });
  }

  void onActivitesChanged(value) {
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

class _subPage0 extends StatelessWidget {
  final ValueChanged onChanged;

  const _subPage0({
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

class _subpage2 extends StatefulWidget {
  const _subpage2({super.key});

  @override
  State<_subpage2> createState() => _subpage2State();
}

class _subpage2State extends State<_subpage2> {
  final _dateController = TextEditingController();
  DateTime date = DateTime.now();
  DateTime? _selectedDate;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(contents[2]),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () async {
            await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            ).then((value) {
              if (value != null) {
                setState(() {
                  _selectedDate = value;
                  _dateController.text = DateFormat('yyyy-MM-dd').format(value);
                });
              }
            });
          },
        ),
      ],
    );
  }
}

class _subpage3 extends StatefulWidget {
  const _subpage3({
    super.key,
  });

  @override
  State<_subpage3> createState() => _subpage3State();
}

class _subpage3State extends State<_subpage3> {
  int _hour = 0;
  int _minute = 0;

  // Future<void> _showTimePickerDialog() async {
  //   await showDialog(context: context, builder: (BuildContext context){
  //     return AlertDialog(
  //       title: Text('시간을 선택해 주세요'),
  //       content: Container(
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             NumberPicker(
  //               value: _hour,
  //               minValue: 0,
  //               maxValue: 23,
  //               onChanged: (value) => setState(() => _hour = value),
  //             ),
  //             NumberPicker(
  //               value: _minute,
  //               minValue: 0,
  //               maxValue: 59,
  //               onChanged: (value) => setState(() => _minute = value),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           child: Text('확인'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             _dateController.text = '$_hour시간 $_minute분';
  //           }
  //         )
  //       ]
  //     );
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(contents[3]),
        const SizedBox(height: 16.0),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumberPicker(
                value: _hour,
                minValue: 0,
                maxValue: 23,
                onChanged: (value) => setState(() => _hour = value),
              ),
              Text("시간"),
              NumberPicker(
                value: _minute,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) => setState(() => _minute = value),
              ),
              Text("분"),
            ],
          ),
        ),
      ],
    );
  }
}

class _subPage4 extends StatefulWidget {
  final ValueChanged onChanged;

  const _subPage4({
    super.key,
    required this.onChanged,
  });

  @override
  State<_subPage4> createState() => _subPage4State();
}

class _subPage4State extends State<_subPage4> {
  List<List<bool>> scheduleData = List.generate(
    24, // 24시간
    (i) => List.generate(7, (j) => false), // 각 요일에 대한 데이터
  );

  // 일정을 추가하는 메서드
  void addSchedule(int hour, int day) {
    setState(() {
      scheduleData[hour][day] = !scheduleData[hour][day];
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
                        addSchedule(hour, day);
                      },
                      child: Container(
                        color: scheduleData[hour][day]
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
