import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:mamasteps_frontend/map/screen/make_path.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/map/screen/tracking_page.dart';
import 'package:numberpicker/numberpicker.dart';

class Body extends StatefulWidget {
  final Position currentPosition;

  final int currentHour;
  final int currentMin;
  final int currentSec;

  final ValueChanged onHourChanged;
  final ValueChanged onMinChanged;
  final ValueChanged onSecChanged;

  final Set<Marker> startClosewayPoints;
  final Set<Marker> endClosewayPoints;

  // final dynamic makeRequest;
  // final void callBack;

  final PageController pageController;

  final ApiResponse apiResponse;
  final VoidCallback acceptResponse;

  const Body({
    super.key,

    required this.currentPosition,

    required this.currentHour,
    required this.currentMin,
    required this.currentSec,

    required this.onHourChanged,
    required this.onMinChanged,
    required this.onSecChanged,

    required this.startClosewayPoints,
    required this.endClosewayPoints,
    // required this.makeRequest,
    // required this.callBack,

    required this.apiResponse,
    required this.acceptResponse,

    required this.pageController,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  late int totalSec = 0;

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
    if (widget.apiResponse.isSuccess) {
      // 서버에 요청하여 경로가 생성되었을 때
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          height: 500,
          child: PageView.builder(
              physics: BouncingScrollPhysics(),
              controller: widget.pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.apiResponse.result.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.apiResponse.result.length) {
                  // 마지막 페이지에 도달 했을 때
                  return Container(
                    child: Text('마지막 페이지'),
                  );
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
                                Path: widget.apiResponse.result[index].polyLine,
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
                                        '${(widget.apiResponse.result[index].totalTimeSeconds / 3600).toInt().toString().padLeft(2,'0')} : ${(widget.apiResponse.result[index].totalTimeSeconds % 3600 / 60).toInt().toString().padLeft(2,'0')} : ${(widget.apiResponse.result[index].totalTimeSeconds % 60).toInt().toString().padLeft(2,'0')}',
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
                                  Path: widget.apiResponse.result[index].polyLine,
                                  currentInitPosition: widget.currentPosition,
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
                              widget.acceptResponse();
                            },
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
