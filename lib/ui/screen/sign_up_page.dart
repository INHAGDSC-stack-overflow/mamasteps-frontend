import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/data/contents.dart';

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
                    _subPage(
                      content: contents[0],
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
            showDatePicker(
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
