import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';

class TrackingScreen extends StatefulWidget {
  // final List<List<PointLatLng>> results;
  final String Path;
  final int hour;
  final int minute;
  final int second;
  final Position currentInitPosition;
  const TrackingScreen({
    super.key,
    // required this.results,
    required this.Path,
    required this.hour,
    required this.minute,
    required this.second,
    required this.currentInitPosition,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool status = false;
  var icon = Icons.play_arrow;
  var color = Colors.blue;
  late Timer _timer;
  late GoogleMapController mapController;
  late Position currentPosition;
  //polyline들의 집합
  Set<Polyline> polylines = {};
  //marker들의 집합
  Set<Marker> markers = {};
  Set<Marker> streamCurrentMarkers = {};
  late List<LatLng> resultList;

  @override
  void initState() {
    //getinformation();
    List<PointLatLng> results = PolylinePoints().decodePolyline(widget.Path);
    resultList = PointToLatLng(results);
    drawPolylines(polylines, resultList);
    drawMarkers(markers, resultList);
    _determinePosition();
    super.initState();
  }
  // getinformation() async {
  //   final dio = Dio();
  //   final resp = await dio.get(
  //     'ip 주소 입력',
  //     options: Options(
  //       headers: {
  //         'authorization': 'Bearer $accessToken',
  //       },
  //     ),
  //   );
  //   final before_convert = PolylinePoints().decodePolyline(resp.data);
  //   final after_convert = before_convert.map((point) {
  //     return LatLng(point.latitude, point.longitude);
  //   }).toList();
  //   drawPolylines();
  //   drawMarkers();
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GoogleMap(
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: resultList[0],
                zoom: 14.0,
              ),
              polylines: polylines,
              markers: markers.union(streamCurrentMarkers),
              mapType: MapType.normal,
              onMapCreated: (controller) {
                setState(
                  () {
                    mapController = controller;
                  },
                );
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _onClick();
                        });
                      },
                      child: Icon(icon),
                      backgroundColor: color,
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onClick() {
    if (icon == Icons.play_arrow) {
      icon = Icons.pause;
      color = Colors.grey;
    } else {
      icon = Icons.play_arrow;
      color = Colors.blue;
    }
  }
  
  void currentMarker(){
    streamCurrentMarkers.clear();
    streamCurrentMarkers.add(
      Marker(
        markerId: MarkerId('current'),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.value('위치 서비스가 비활성화되어 있습니다.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.value('위치 권한이 거부되었습니다.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다, 설정에서 변경해주세요.');
    }

    Position? lastPosition;
    Timer? movementTimer;

    StreamSubscription mySubScript = Geolocator.getPositionStream().listen(
      (Position position) {
        print(position);

        currentPosition = position;

        // 마지막 위치와 현재 위치가 동일한지 확인
        if (lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            lastPosition!.latitude,
            lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // 사용자가 움직이지 않음
          if (distance < 10) {
            if (movementTimer == null) {
              movementTimer = Timer(
                Duration(seconds: 5),
                () {
                  sendSmsMessageToGuardian('사용자가 움직이지 않음', ['01012345678']);
                  print('사용자가 움직이지 않음');
                },
              );
            }
          }
        } else {
          // 사용자가 움직였음, 타이머 리셋
          movementTimer?.cancel();
          movementTimer = null;
        }
        double distance = Geolocator.distanceBetween(
          widget.currentInitPosition.latitude,
          widget.currentInitPosition.longitude,
          position.latitude,
          position.longitude,
        );
        if(widget.minute == 0 && widget.second == 0 && widget.hour == 0 && distance < 10){// 목적지에 도착했을 때, 시간과 거리로 판단
          movementTimer?.cancel();
          movementTimer = null;
          // 위치 구독 해제 코드 추가해야함
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => MapPage(),
            ),
                (route) => false,
          );
        }

        // 마지막 위치 업데이트
        lastPosition = position;
      },
      onError: (e) {
        print(e);
      },
    );
  }

  void sendSmsMessageToGuardian(String message, List<String> recipents) async {
    await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    // 사용자의 보호자에게 문자 메시지를 보냅니다.
  }
}

class countDownTimer extends StatefulWidget {
  final int hour;
  final int minute;
  final int second;

  const countDownTimer({
    super.key,
    required this.hour,
    required this.minute,
    required this.second,
  });

  @override
  _countDownTimerState createState() => _countDownTimerState();
}

class _countDownTimerState extends State<countDownTimer> {
  late Duration duration;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  void initTimer() {
    duration = Duration(
        hours: widget.hour, minutes: widget.minute, seconds: widget.second);
  }

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (duration.inSeconds > 0) {
          setState(() {
            duration = duration - Duration(seconds: 1);
            isRunning = true;
          });
        } else {
          timer?.cancel();
          setState(() {
            isRunning = false;
          });
        }
      });
    }
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void resetTimer() {
    if (timer != null) {
      timer?.cancel();
    }
    setState(() {
      duration = Duration(
          hours: widget.hour,
          minutes: widget.minute,
          seconds: widget.second); // 초기 시간으로 재설정
      isRunning = false;
    });
  }

  void showStopDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('지금 중단하면 기록은 삭제돼요!\n 그래도 중단하시겠어요?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                  (route) => false,
                );
              },
              child: Text('예'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('아니요'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
              child: Container(
            child: Column(
              children: [
                Align(
                  child: Text('소요 시간'),
                  alignment: Alignment.topLeft,
                ),
                Center(
                  child: Text('$hours:$minutes:$seconds',
                      style: TextStyle(fontSize: 48)),
                ),
              ],
            ),
          )),
          SizedBox(height: 20),
          Row(
            children: [
              (isRunning)
                  ? IconButton(
                      onPressed: pauseTimer,
                      icon: Icon(Icons.pause),
                    )
                  : IconButton(
                      onPressed: startTimer,
                      icon: Icon(Icons.play_arrow),
                    ),
              IconButton(
                onPressed: showStopDialog,
                icon: Icon(Icons.stop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// Widget _watch() {
//   return Align(
//     alignment: Alignment.topCenter,
//     child: Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: 100,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '00',
//               style: TextStyle(fontSize: 80),
//             ), //시
//             const SizedBox(width: 10),
//             Text(
//               ':',
//               style: TextStyle(fontSize: 80),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               '00',
//               style: TextStyle(fontSize: 80),
//             ), //분
//             const SizedBox(width: 10),
//             Text(
//               ':',
//               style: TextStyle(fontSize: 80),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               '99',
//               style: TextStyle(fontSize: 80),
//             ), //초
//           ],
//         ),
//       ),
//     ),
//   );
// }