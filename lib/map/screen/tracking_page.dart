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
  // final List<List<PointLatLng>> results;
  final String Path;
  // final int hour;
  // final int minute;
  // final int second;
  final int totalSeconds;
  final Position currentInitPosition;
  const TrackingScreen({
    super.key,
    // required this.results,
    required this.Path,
    // required this.hour,
    // required this.minute,
    // required this.second,
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
  late Timer _timer;
  late GoogleMapController mapController;
  late Position currentPosition;
  //polyline들의 집합
  Set<Polyline> polylines = {};
  //marker들의 집합
  Set<Marker> markers = {};
  Set<Marker> streamCurrentMarkers = {};
  late List<LatLng> resultList;
  late int hour=0;
  late int minute=0;
  late int second=0;
  late List<int> numbers;


  @override
  void initState() {
    //getinformation();
    List<PointLatLng> results = PolylinePoints().decodePolyline(widget.Path);
    resultList = PointToLatLng(results);
    drawPolylines(polylines, resultList);
    drawMarkers(markers, resultList);
    _determinePosition();
    totalToHMS(hour, minute, second, widget.totalSeconds);
    super.initState();
  }

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
            countDownTimer(totalSeconds: widget.totalSeconds, showStopDialog: showStopDialog),
          ],
        ),
      ),
    );
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

    Geolocator.getPositionStream().listen(
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
        if(minute == 0 && second == 0 && hour == 0 && distance < 10){// 목적지에 도착했을 때, 시간과 거리로 판단
          movementTimer?.cancel();
          movementTimer = null;
          // 위치 구독 해제 코드 추가해야함
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => RootTab(),
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