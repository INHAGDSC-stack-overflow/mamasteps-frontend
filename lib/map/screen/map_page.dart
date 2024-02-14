import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/screen/make_path.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/map/screen/tracking_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;

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
  Set<Marker> startClosewayPoints = {};
  Set<Marker> endClosewayPoints = {};
  late Position currentPosition;
  RequestData requestData = RequestData(
    targetTime: 0,
    origin: Coordinate(latitude: 0, longitude: 0),
    startCloseIntermediates: [],
    endCloseIntermediates: [],
  );
  ApiResponse apiResponse = ApiResponse(
    isSuccess: false,
    code: '',
    message: '',
    result: [],
  );

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
                apiResponse: apiResponse,
                endClosewayPoints: endClosewayPoints,
                startClosewayPoints: startClosewayPoints,
                pageController: pageController,
                currentPosition: currentPosition,
                makeRequest: makeRequest),
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

  void clientToServerTimeConvert() {
    setState(() {
      totalSec += currentHour * 3600;
      totalSec += currentMin * 60;
      totalSec += currentSec;
    });
  }

  void acceptResponse(value) {
    setState(() {
      apiResponse = ApiResponse.fromJson(value);
      if (apiResponse.isSuccess) {
        final List<String> results =
            apiResponse.result.map((route) => route.polyLine).toList();
        acceptResponse(results);
      } else {
        print('Server Error');
      }
    });
  }

  void makeRequest() async {
    final url = 'https://dev.mamasteps.dev/api/v1/routes/computeRoutes';
    final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    List<Coordinate> redMarker = convertMarkersToList(startClosewayPoints);
    List<Coordinate> blueMarker = convertMarkersToList(endClosewayPoints);

    clientToServerTimeConvert();

    var requestData = RequestData(
        targetTime: totalSec,
        origin: Coordinate(
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude),
        startCloseIntermediates: redMarker,
        endCloseIntermediates: blueMarker);

    Map<String, dynamic> jsonData = requestData.toJson();
    String jsonString = jsonEncode(jsonData);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $AccessToken',
        },
        body: jsonString,
      );

      print('Server Response: ${response.statusCode}');
      print('Exception: ${response.body}');

      if (response.statusCode == 200) {
        acceptResponse(response.body);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleLogin(),
          ),
          (route) => false,
        );
        print('Server Error');
      }
    } catch (error) {
      print('Server Error');
    }
  }

  List<Coordinate> convertMarkersToList(Set<Marker> markers) {
    return markers.map((marker) {
      return Coordinate(
        latitude: marker.position.latitude,
        longitude: marker.position.longitude,
      );
    }).toList();
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
  final Set<Marker> startClosewayPoints;
  final Set<Marker> endClosewayPoints;
  final Position currentPosition;
  final void makeRequest;
  final ApiResponse apiResponse;
  const _Body({
    super.key,
    required this.pageController,
    required this.currentHour,
    required this.currentMin,
    required this.currentSec,
    required this.onHourChanged,
    required this.onMinChanged,
    required this.onSecChanged,
    required this.startClosewayPoints,
    required this.endClosewayPoints,
    required this.currentPosition,
    required this.makeRequest,
    required this.apiResponse,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late int totalSec;
  List<String> resultsString = [];
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
    if (widget.apiResponse.isSuccess == true) {
      // 서버에 요청하여 경로가 생성되었을 때
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          height: 500,
          child: PageView.builder(
              physics: BouncingScrollPhysics(),
              controller: widget.pageController,
              scrollDirection: Axis.horizontal,
              itemCount: resultsString.length + 1,
              itemBuilder: (context, index) {
                if (index == resultsString.length) {
                  // 마지막 페이지에 도달 했을 때
                  return Container(
                    child: Text('마지막 페이지'),
                  );
                } else {
                  // 마지막 페이지가 아닐 때
                  return SizedBox(
                    width: screenWidth,
                    height: 400,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MapScreen(
                          Path: widget.apiResponse.result[index].polyLine,
                        ),
                      ),
                      elevation: 0,
                    ),
                  );
                }
              }),
        ),
      );
    } else {
      // 경로가 없어서 서버에 페이지 요청하기 위해 정보를 입력하는 페이지
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
                                    endClosewayPoints: widget.endClosewayPoints,
                                    startClosewayPoints:
                                        widget.startClosewayPoints,
                                  ),
                                ),
                              );
                              widget.makeRequest;
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

class RequestData {
  final int targetTime;
  final Coordinate origin;
  final List<Coordinate> startCloseIntermediates;
  final List<Coordinate> endCloseIntermediates;

  RequestData({
    required this.targetTime,
    required this.origin,
    required this.startCloseIntermediates,
    required this.endCloseIntermediates,
  });

  Map<String, dynamic> toJson() => {
        'targetTime': targetTime,
        'origin': origin.toJson(),
        'startCloseIntermediates':
            startCloseIntermediates.map((i) => i.toJson()).toList(),
        'endCloseIntermediates':
            endCloseIntermediates.map((i) => i.toJson()).toList(),
      };
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class ApiResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<Route> result;

  ApiResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        isSuccess: json['isSuccess'],
        code: json['code'],
        message: json['message'],
        result: List<Route>.from(json['result'].map((x) => Route.fromJson(x))),
      );
}

class Route {
  final int routeId;
  final int routesProfileId;
  final CreatedWaypoint createdWaypoint;
  final String polyLine;
  final int totalDistanceMeters;
  final int totalTimeSeconds;
  final String createdAt;
  final String updatedAt;

  Route({
    required this.routeId,
    required this.routesProfileId,
    required this.createdWaypoint,
    required this.polyLine,
    required this.totalDistanceMeters,
    required this.totalTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        routeId: json['routeId'],
        routesProfileId: json['routesProfileId'],
        createdWaypoint: CreatedWaypoint.fromJson(json['createdWaypoint']),
        polyLine: json['polyLine'],
        totalDistanceMeters: json['totalDistanceMeters'],
        totalTimeSeconds: json['totalTimeSeconds'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}

class CreatedWaypoint {
  final double latitude;
  final double longitude;

  CreatedWaypoint({
    required this.latitude,
    required this.longitude,
  });

  factory CreatedWaypoint.fromJson(Map<String, dynamic> json) =>
      CreatedWaypoint(
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
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
