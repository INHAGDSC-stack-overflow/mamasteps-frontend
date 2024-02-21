import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/component/timer/count_down_timer.dart';
import 'package:mamasteps_frontend/map/component/util/map_server_communication.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/storage/user/user_data.dart';
import 'package:mamasteps_frontend/ui/screen/root_tab.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:telephony/telephony.dart';

class TrackingScreen extends StatefulWidget {
  final String Path;
  final int totalSeconds;
  final Position currentInitPosition;
  final double totalMeter;

  const TrackingScreen({
    super.key,
    required this.Path,
    required this.currentInitPosition,
    required this.totalSeconds,
    required this.totalMeter,
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
  late StreamSubscription<Position>? positionSubscription;
  late int afterRating = 0;

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
  bool isSelect = false;
  bool ismiddle = false;

  @override
  void initState() {
    super.initState();
    //getinformation();
    List<PointLatLng> results = PolylinePoints().decodePolyline(widget.Path);
    resultList = PointToLatLng(results);
    drawPolylines(polylines, resultList);
    drawMarkers(markers, resultList);
    initTimer();
    // startTimer();
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
            isSelect
                ? Positioned(
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
                            child: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow),
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
                  )
                : Positioned(
                    bottom: 25,
                    right: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isSelect = true;
                          startTimer();
                        });
                      },
                      child: Text('산책 시작'),
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
      positionSubscription = Geolocator.getPositionStream().listen(
        (Position position) {
          print(position);

          currentPosition = position;

          streamCurrentMarkers.clear();
          streamCurrentMarkers.add(
            Marker(
              markerId: MarkerId('current'),
              position:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            ),
          );

          // 마지막 위치와 현재 위치가 동일한지 확인 사용자가 움직이는지 추적하는 거리
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
                  Duration(minutes: 5),
                  () {
                    if (isRunning) {
                      pauseTimer();
                    }
                    showSendSmsDialog();
                    print('사용자가 움직이지 않음');
                  },
                );
              }
            }
          } else {
            // 사용자가 움직였음, 타이머 리셋
            print('사용자가 다시 움직임');
            movementTimer?.cancel();
            movementTimer = null;
          }
          double initDistance = Geolocator.distanceBetween(
            widget.currentInitPosition.latitude,
            widget.currentInitPosition.longitude,
            position.latitude,
            position.longitude,
          );
          // 목적지에 도착했을 때, 최대로 멀리간 거리 기준으로 판단
          if (initDistance > widget.totalMeter * 0.5 && !ismiddle) {
            print('중간지점 도착');
            ismiddle = true;
          } else if (initDistance < 25 && ismiddle) {
            print('도착');
            int completeTimeSeconds = widget.totalSeconds - duration.inSeconds;
            movementTimer?.cancel();
            movementTimer = null;
            _stopTracking();
            addRecord(completeTimeSeconds);
            optimizeSpeed(widget.totalMeter, completeTimeSeconds);
            afterTrackingDialog();
          }
          // 마지막 위치 업데이트
          lastPosition = position;
        },
        onError: (e) {
          print(e);
        },
      );
    });
  }

  void afterTrackingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('산책 완료'),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                Text('산책의 만족도를 평가해 주세요'),
                // NumberPicker(
                //     axis: Axis.horizontal,
                //     minValue: -9,
                //     maxValue: 9,
                //     value: afterRating,
                //     onChanged: (value) {
                //       setState(() {
                //         afterRating = value;
                //       });
                //     })
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '평가',
                    hintText: '-9 ~ 9 까지의 수를 입력해 주세요',
                  ),
                  onChanged: (value) {
                    afterRating = int.parse(value);
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                feedbackTime(afterRating);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => RootTab()),
                  (route) => false,
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 보호자 문자 보내기 팝업 창
  void showSendSmsDialog() {
    Timer? localtimer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        localtimer = Timer(Duration(minutes: 1), () {
          String recipient = user_storage.read(key: 'guardian_phone').toString();
          print('보호자 번호: $recipient');
          sendSmsMessageToGuardian('테스트용 문자', [recipient]);
          localtimer?.cancel();
          Navigator.pop(context);
          afterSendSmsDialog();
        });

        return AlertDialog(
          content: Text('보호자에게 문자를 전송합니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                localtimer?.cancel();
                resumeTimer();
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  // 보호자에게 문자 전송 후 팝업 창
  void afterSendSmsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('보호자에게 문자를 전송했습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => RootTab()),
                    (route) => false);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 보호자에게 문자 보내기
  void sendSmsMessageToGuardian(String message, List<String> recipents) async {
    final Telephony telephony = Telephony.instance;
    bool? permissions = await telephony.requestPhoneAndSmsPermissions;
    if (permissions == true) {
      for (String recipent in recipents) {
        await telephony.sendSms(
          to: recipent,
          message: message,
        );
      }
    }
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

  void _stopTracking() {
    positionSubscription?.cancel();
    positionSubscription = null;
  }
}
