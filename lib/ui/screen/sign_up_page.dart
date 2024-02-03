import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:calendar_view/calendar_view.dart';

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

class _subPage4 extends StatelessWidget {
  final ValueChanged onChanged;

  const _subPage4({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(contents[0]),
        const SizedBox(height: 16.0),
        Expanded(
          child: WeekView(
            controller: EventController(),
            eventTileBuilder: (date, events, boundry, start, end) {
              return Container();
            },
            fullDayEventBuilder: (events, date) {
              return Container();
            },
            width: MediaQuery.of(context).size.width * 0.8,
            minDay: DateTime.now(),
            maxDay: DateTime.now(),
            initialDay: DateTime.now(),
            heightPerMinute: 1,
            eventArranger: SideEventArranger(),
            onEventTap: (events, date) => print(events),
            onDateLongPress: (date) => print(date),
            onDateTap: (DateTime date) async {
              await _showMyDialog(context);
            },
            startDay: WeekDays.sunday,
          ),
        ),
      ],
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          title: Text('요일을 선택해 주세요'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text('월요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('화요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('수요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('목요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('금요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('토요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('일요일'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
