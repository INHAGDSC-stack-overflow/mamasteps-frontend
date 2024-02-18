import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/component/timer/count_down_timer.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';

class TrackingScreen extends StatefulWidget {
  final String Path;
  final int totalSeconds;
  final Position currentInitPosition;

  const TrackingScreen({
    super.key,
    required this.Path,
    required this.currentInitPosition,
    required this.totalSeconds,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool status = false;
  var icon = Icons.play_arrow;
  var color = Colors.blue;
  late Timer timer;
  late GoogleMapController mapController;
  late Position currentPosition;
  late Duration duration;

  //polyline들의 집합
  Set<Polyline> polylines = {};
  //marker들의 집합
  Set<Marker> markers = {};
  Set<Marker> streamCurrentMarkers = {};
  late List<LatLng> resultList;
  late int hour;
  late int minute;
  late int second;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    //getinformation();
    List<PointLatLng> results = PolylinePoints().decodePolyline(widget.Path);
    resultList = PointToLatLng(results);
    drawPolylines(polylines, resultList);
    drawMarkers(markers, resultList);
    initTimer();
    startTimer();
    _determinePosition();
  }

  Duration timeConvert(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void initTimer() {
    setState(() {
      duration = timeConvert(widget.totalSeconds);
      hour = duration.inHours;
      minute = duration.inMinutes.remainder(60);
      second = duration.inSeconds.remainder(60);
      isRunning = false;
    });
  }

  void startTimer() {
    if (!isRunning) {
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
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void resumeTimer() {
    if (!isRunning && duration.inSeconds > 0) {
      startTimer();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: GoogleMap(
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
            ),
            Positioned(
              top: 25,
              left: 10,
              right: 10,
              child: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Card(
                      child: Center(
                        child: Text('$hours:$minutes:$seconds',
                            style: TextStyle(fontSize: 48)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        isRunning ? pauseTimer() : resumeTimer();
                      },
                      child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showStopDialog();
                      },
                      child: Icon(Icons.stop),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void currentMarker() {
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

    setState(() {
      Geolocator.getPositionStream().listen(
        (Position position) {
          print(position);

          currentPosition = position;

          streamCurrentMarkers.clear();
          streamCurrentMarkers.add(
            Marker(
              markerId: MarkerId('current'),
              position:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );

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
                    //sendSmsMessageToGuardian('사용자가 움직이지 않음', ['01012345678']);
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
          // if (minute == 0 && second == 0 && hour == 0 && distance < 10) {
          //   // 목적지에 도착했을 때, 시간과 거리로 판단
          //   movementTimer?.cancel();
          //   movementTimer = null;
          //   // 위치 구독 해제 코드 추가해야함
          //   // Navigator.of(context).pushAndRemoveUntil(
          //   //   MaterialPageRoute(
          //   //     builder: (_) => RootTab(),
          //   //   ),
          //   //   (route) => false,
          //   // );
          // }

          // 마지막 위치 업데이트
          lastPosition = position;
        },
        onError: (e) {
          print(e);
        },
      );
    });
  }

  // void sendSmsMessageToGuardian(String message, List<String> recipents) async {
  //   SmsSender sender = new SmsSender();
  //   String address = recipents[0];
  //   sender.sendSms(new SmsMessage(address, message));
  //   // 사용자의 보호자에게 문자 메시지를 보냅니다.
  // }

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
                    builder: (context) => RootTab(),
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
