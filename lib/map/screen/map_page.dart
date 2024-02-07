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
  // final dio = Dio();
  int _currentHour = 0;
  int _currentMin = 0;
  int _currentSec = 0;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
            Expanded(
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
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 4,
              child: Column(
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
                                            value: _currentHour,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  _currentHour = value;
                                                },
                                              );
                                            },
                                            textMapper: (numberText) => numberText.padLeft(2, '0'),
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
                                            value: _currentMin,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  _currentMin = value;
                                                },
                                              );
                                            },
                                            textMapper: (numberText) => numberText.padLeft(2, '0'),
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
                                            value: _currentSec,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  _currentSec = value;
                                                },
                                              );
                                            },
                                            textMapper: (numberText) => numberText.padLeft(2, '0'),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
