import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final pageController = PageController(viewportFraction: 0.877);
  double currentPage = 0;
  int currentHour = 0;
  int currentMin = 0;
  int currentSec = 0;

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toDouble();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
            _Header(),
            _Body(
                currentHour: currentHour,
                currentMin: currentMin,
                currentSec: currentSec,
                onHourChanged: onHourChanged,
                onMinChanged: onMinChanged,
                onSecChanged: onSecChanged,
                pageController: pageController),
          ],
        ),
      ),
    );
  }

  void onHourChanged(value) {
    setState(() {
      currentHour = value;
    });
  }

  void onMinChanged(value) {
    setState(() {
      currentMin = value;
    });
  }

  void onSecChanged(value) {
    setState(() {
      currentSec = value;
    });
  }
}

//상단 헤더
class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
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
                  "산책 경로 만들기",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final PageController pageController;
  final int currentHour;
  final int currentMin;
  final int currentSec;
  final ValueChanged onHourChanged;
  final ValueChanged onMinChanged;
  final ValueChanged onSecChanged;
  const _Body({
    super.key,
    required this.pageController,
    required this.currentHour,
    required this.currentMin,
    required this.currentSec,
    required this.onHourChanged,
    required this.onMinChanged,
    required this.onSecChanged,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            '산책 시간 설정',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth,
                          height: 100,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: NumberPicker(
                                          minValue: 0,
                                          maxValue: 24,
                                          value: widget.currentHour,
                                          onChanged: widget.onHourChanged,
                                          textMapper: (numberText) =>
                                              numberText.padLeft(2, '0'),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(':'),
                                        width: 10,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: NumberPicker(
                                          minValue: 0,
                                          maxValue: 59,
                                          value: widget.currentMin,
                                          onChanged: widget.onMinChanged,
                                          textMapper: (numberText) =>
                                              numberText.padLeft(2, '0'),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(':'),
                                        width: 10,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: NumberPicker(
                                          minValue: 0,
                                          maxValue: 59,
                                          value: widget.currentSec,
                                          onChanged: widget.onSecChanged,
                                          textMapper: (numberText) =>
                                              numberText.padLeft(2, '0'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            '산책 경로 설정',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          child: PageView(
                            physics: BouncingScrollPhysics(),
                            controller: widget.pageController,
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: screenWidth,
                                height: 400,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MapScreen(),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth,
                                height: 400,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MapScreen(),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth,
                                height: 400,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MapScreen(),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeSelectDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('시간을 선택해주세요'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('시간을 선택해주세요'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
