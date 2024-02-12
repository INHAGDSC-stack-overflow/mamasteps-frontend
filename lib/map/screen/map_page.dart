
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:mamasteps_frontend/map/screen/make_path.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/map/screen/tracking_page.dart';
import 'package:numberpicker/numberpicker.dart';

bool check = false;
final List<String> resultsString = [
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
];

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
  int totalSec = 0;
  Set<Marker> wayPoints = {};
  List<String> resultsString=[];

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => TrackingScreen(
            //       Path: resultsString[0],
            //       hour: currentHour,
            //       minute: currentMin,
            //       second: currentSec,
            //     ),
            //   ),
            // );

          },
          child: Text('산책 시작'),
          backgroundColor: Color(0xFFF5F5F5),
        ),
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
            _Header(),
            _Body(
                currentHour: currentHour,
                currentMin: currentMin,
                currentSec: currentSec,
                wayPoint: wayPoints,
                onWayPointChanged: onWayPointChanged,
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

  void onWayPointChanged(value) {
    setState(() {
      wayPoints = value;
    });
  }

  void serverToClientTimeConvert(value) {
    setState(() {
      totalSec = value;
      currentHour = value ~/ 3600;
      currentMin = (value % 3600) ~/ 60;
      currentSec = value % 60;
    });
  }

  void clientToServerTimeConvert(value) {
    setState(() {
      totalSec += currentHour * 3600;
      totalSec += currentMin * 60;
      totalSec += currentSec;
    });
  }

  void makeRequest() async {}

  Future<String> sendPostRequest({
    required Set<Marker> wayPoints,
    required int totalSec,
  }) async {
    final String apiUrl = 'http://3.38.34.206:8080/api/v1/auth/login';

    Map<String, dynamic> requestData = {
      "wayPoints": wayPoints,
      "totalSec": totalSec,
    };

    String requestBody = json.encode(requestData);

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        return 'POST request successful! Response: ${utf8.decode(response.bodyBytes)}';
      } else {
        return 'Failed to send POST request. Status code: ${response.statusCode}\nResponse: ${utf8.decode(response.bodyBytes)}';
      }
    } catch (error) {
      return 'Error sending POST request: $error';
    }
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
  final Set<Marker> wayPoint;
  final ValueChanged onWayPointChanged;
  final ValueChanged onHourChanged;
  final ValueChanged onMinChanged;
  final ValueChanged onSecChanged;
  const _Body({
    super.key,
    required this.pageController,
    required this.currentHour,
    required this.currentMin,
    required this.currentSec,
    required this.wayPoint,
    required this.onWayPointChanged,
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
                        mapScreenBuilder(context, screenWidth),
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

  // void _showTimeSelectDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('시간을 선택해주세요'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('시간을 선택해주세요'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('확인'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget mapScreenBuilder(BuildContext context, double screenWidth) {
    if (check == true) {
      return SizedBox(
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
                  child: MapScreen(
                    Path: resultsString[0],
                  ),
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
                  child: MapScreen(
                    Path: resultsString[1],
                  ),
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
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        check = !check;
                      });
                    },
                    child: Text('산책 경로를 설정해주세요'),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: screenWidth,
        height: 400,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: IconButton(
                onPressed: () async {
                  setState(
                    () async {
                      Set<Marker> wayPoint = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (__) => MakePath(),
                        ),
                      );
                      widget.onWayPointChanged(wayPoint);
                      check = true;
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ),
          ),
        ),
      );
    }
  }
}
