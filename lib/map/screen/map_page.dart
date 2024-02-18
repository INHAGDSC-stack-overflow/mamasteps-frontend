import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/map/component/util/get_position.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;
import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/screen/make_path.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/map/screen/tracking_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:mamasteps_frontend/map/component/util/map_server_communication.dart';
// import 'package:mamasteps_frontend/map/screen/map_page_body.dart';
// import 'package:mamasteps_frontend/map/screen/map_page_header.dart';

bool check = false;
final List<String> resultsString = [
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
];

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
  });

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Position currentPosition = Position(
    latitude: 37.5665,
    longitude: 126.9780,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

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

  List<MadeRoute> serverRoute = [];
  List<MadeRoute> savedRoute = [];

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toDouble();
      });
    });
    getInitPosition().then((value) {
      setState(() {
        currentPosition = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
            child: ListView.builder(
          itemCount: savedRoute.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              );
            }
            return ListTile(
              title: Text('Item $index'),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TrackingScreen(
                //       Path: savedRoute[index - 1].polyLine,
                //       currentInitPosition: currentPosition,
                //       totalSeconds: savedRoute[index - 1].totalTimeSeconds,
                //     ),
                //   ),
                // );
                setState(() {
                  manageRouteList(savedRoute[index-1], 'clear');
                  manageRouteList(savedRoute[index-1], 'add');
                });
              },
            );
          },
          padding: EdgeInsets.zero,
        )),
        floatingActionButton: (apiResponse.isSuccess)
            ? FloatingActionButton(
                onPressed: () {
                  int index = currentPage.toInt();
                  // SaveRoute(apiResponse.result[index]);
                  setState(() {
                    manageSavedRouteList(serverRoute[index], 'add');
                  });
                },
                child: Text('경로 저장'),
              )
            : null,
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
                    ),
                    Positioned(
                      right: 0,
                      top: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                  child: mapScreenBuilder(context, screenWidth)),
            ),
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

  void onCurrentPageChanged(value) {
    setState(() {
      currentPage = value;
    });
  }

  void serverToClientTimeConvert(value) {
    setState(() {
      totalToHMS(currentHour, currentMin, currentSec, totalSec);
    });
  }

  void clientToServerTimeConvert() {
    setState(() {
      HMSToTotal(currentHour, currentMin, currentSec, totalSec);
    });
  }

  // void acceptResponse(value) {
  //   setState(() {
  //     apiResponse = ApiResponse.fromJson(value);
  //     if (apiResponse.isSuccess) {
  //       final List<String> results =
  //           apiResponse.result.map((route) => route.polyLine).toList();
  //     } else {
  //       print('Server Error');
  //     }
  //   });
  // }

  // void acceptResponse(value) {
  //   setState(() {
  //     apiResponse = ApiResponse.fromJson(value);
  //     if (apiResponse.isSuccess) {
  //       final List<String> results =
  //       apiResponse.result.map((route) => route.polyLine).toList();
  //     } else {
  //       print('Server Error');
  //     }
  //   });
  // }

  void acceptResponse() async {
    final value = await makeRequest();
    print(value.result[0].polyLine);
    setState(() {
      manageRouteList(value.result, 'addAll');
      apiResponse = value;
    });
  }

  void manageRouteList(data, order){
    setState(() {
      if(order == 'add'){
        serverRoute.add(data);
      } else if(order == 'delete'){
        serverRoute.remove(data);
      } else if(order == 'clear'){
        serverRoute.clear();
      } else if(order == 'addAll'){
        serverRoute.addAll(data);
      }
    });
  }

  void manageSavedRouteList(data, order){
    setState(() {
      if(order == 'add'){
        savedRoute.add(data);
      } else if(order == 'delete'){
        savedRoute.remove(data);
      } else if(order == 'clear'){
        savedRoute.clear();
      }
    });
  }


  // List<Coordinate> convertMarkersToList(Set<Marker> markers) {
  //   return markers.map((marker) {
  //     return Coordinate(
  //       latitude: marker.position.latitude,
  //       longitude: marker.position.longitude,
  //     );
  //   }).toList();
  // }

  Widget mapScreenBuilder(BuildContext context, double screenWidth) {
    if (serverRoute.isNotEmpty) {
      // 서버에 요청하여 경로가 생성되었을 때
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          height: 500,
          child: PageView.builder(
              physics: BouncingScrollPhysics(),
              controller: pageController,
              scrollDirection: Axis.horizontal,
              itemCount: serverRoute.length + 1,
              itemBuilder: (context, index) {
                if (index == serverRoute.length) {
                  // 마지막 페이지에 도달 했을 때
                  setState(() {
                    acceptResponse();
                  });
                } else {
                  // 마지막 페이지가 아닐 때
                  return InkWell(
                    child: SizedBox(
                      width: screenWidth,
                      height: 400,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              MapScreen(
                                Path: serverRoute[index].polyLine,
                              ),
                              Positioned(
                                top: 350,
                                left: 5,
                                child: Container(
                                  width: screenWidth * 0.8,
                                  height: 100,
                                  child: Card(
                                    child: Center(
                                      child: Text(
                                        '${(serverRoute[index].totalTimeSeconds / 3600).toInt().toString().padLeft(2, '0')} : ${(serverRoute[index].totalTimeSeconds % 3600 / 60).toInt().toString().padLeft(2, '0')} : ${(serverRoute[index].totalTimeSeconds % 60).toInt().toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingScreen(
                                  Path: apiResponse.result[index].polyLine,
                                  currentInitPosition: currentPosition,
                                  totalSeconds: totalSec),
                            ));
                      });
                    },
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
                                        value: currentHour,
                                        onChanged: onHourChanged,
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
                                        value: currentMin,
                                        onChanged: onMinChanged,
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
                                        value: currentSec,
                                        onChanged: onSecChanged,
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
                        // SizedBox(
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         timeConvert();
                        //       });
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => MakePath(
                        //             currentPosition: widget.currentPosition,
                        //             targetTime: totalSec,
                        //             endClosewayPoints: widget.endClosewayPoints,
                        //             startClosewayPoints:
                        //                 widget.startClosewayPoints,
                        //             makeRequest: widget.makeRequest,
                        //             callback: widget.callBack,
                        //             onCheckChange: onCheckChange,
                        //           ),
                        //         ),
                        //       );
                        //       //widget.makeRequest;
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: (widget.currentHour == 0 &&
                        //               widget.currentMin == 0 &&
                        //               widget.currentSec == 0)
                        //           ? Colors.grey
                        //           : Colors.blue,
                        //     ),
                        //     child: Text(
                        //       '경유지 추가하기',
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                            onPressed: () async {
                              // setState(() {
                              //   timeConvert();
                              // });
                              // widget.makeRequest(
                              //   (String response) {
                              //     widget.callBack(response);
                              //   },
                              //   context,
                              // );

                              // final response = widget.makeRequest();
                              // widget.acceptResponse(response);
                              // onCheckChange();
                              acceptResponse();
                            },
                            child: Text(
                              '경유지 없이 경로 만들기',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (currentHour == 0 &&
                                      currentMin == 0 &&
                                      currentSec == 0)
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
}
