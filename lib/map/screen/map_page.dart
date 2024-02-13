import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
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
  late Position currentPosition;
  List<String> resultsString = [];

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toDouble();
      });
    });
    _determinePosition().then((value) {
      setState(() {
        currentPosition = value;
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
                // startCloseWayPoints: startClosewayPoints,
                // endCloseWayPoints: endClosewayPoints,
                // onWayPointChanged: startWayPointAdd,
                onHourChanged: onHourChanged,
                onMinChanged: onMinChanged,
                onSecChanged: onSecChanged,
                pageController: pageController,
                currentPosition: currentPosition),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되었는지 확인합니다.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면, 사용자에게 위치 서비스를 활성화하도록 요청합니다.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부되면, 에러를 반환합니다.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부되면, 에러를 반환합니다.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 권한이 허용되면, 현재 위치를 얻습니다.
    return await Geolocator.getCurrentPosition();
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

  void acceptResponse(value) {
    setState(() {
      resultsString = value;
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
  final Position currentPosition;
  const _Body({
    super.key,
    required this.pageController,
    required this.currentHour,
    required this.currentMin,
    required this.currentSec,
    required this.onHourChanged,
    required this.onMinChanged,
    required this.onSecChanged,
    required this.currentPosition,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late int totalSec;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      flex: 3,
      child:
          SingleChildScrollView(child: mapScreenBuilder(context, screenWidth)),
    );
  }

  Widget mapScreenBuilder(BuildContext context, double screenWidth) {
    if (check == true) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          height: 500,
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
        ),
      );
    } else {
      return Column(
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                        itemHeight: 30,
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
                                        itemHeight: 30,
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
                                        itemHeight: 30,
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
              SizedBox(
                width: screenWidth,
                height: 200,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Image.asset(
                              'asset/image/make_path_with_waypoint.png'),
                        ),
                        SizedBox(
                          child: Text(
                            '경유지를 추가합니다.\n지정한 경유지를 포함하여 목표시간을\n충족하는 경로를 생성합니다.',
                            style: TextStyle(
                              fontSize: 8,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                timeConvert();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MakePath(
                                    currentPosition: widget.currentPosition,
                                    targetTime: totalSec,
                                    // onWayPointChanged: widget.onWayPointChanged,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (widget.currentHour == 0 &&
                                      widget.currentMin == 0 &&
                                      widget.currentSec == 0)
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                            child: Text(
                              '경유지 추가하기',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth,
                height: 200,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Image.asset(
                              'asset/image/make_path_without_waypoint.png'),
                        ),
                        SizedBox(
                          child: Text(
                            '현재 위치에서 목표 시간을 충족하고\n 돌아오는 경로를 생성합니다.',
                            style: TextStyle(
                              fontSize: 8,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              '경유지 없이 경로 만들기',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (widget.currentHour == 0 &&
                                      widget.currentMin == 0 &&
                                      widget.currentSec == 0)
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  void timeConvert() {
    setState(() {
      totalSec = widget.currentHour * 3600 +
          widget.currentMin * 60 +
          widget.currentSec;
    });
  }
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
