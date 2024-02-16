import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';

Future<Position> getInitPosition() async {
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

Future<dynamic> getPositionStream(Function(Position) callBack, BuildContext context, int hour, int min, int sec, currentInitPosition) async {
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

      callBack(position);
      // 마지막 위치와 현재 위치가 동일한지 확인
      if (lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance < 10) {
          // 사용자가 움직이지 않음
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
        currentInitPosition.latitude,
        currentInitPosition.longitude,
        position.latitude,
        position.longitude,
      );
      if (hour == 0 &&
          min == 0 &&
          sec == 0 &&
          distance < 10) {
        // 목적지에 도착했을 때, 시간과 거리로 판단
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
