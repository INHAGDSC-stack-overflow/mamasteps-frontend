/*
  - 사용자가 경로를 설정하는 화면
  - 사용자가 경유지를 설정할 수 있음
  - 경유지는 startClose, endClose로 구분
  - 경로 검색을 누를 시 서버에 시간과 경유지 정보를 넘기며 요청을 전송해야 함
  - undo 기능과(보류) 경유지 전체 삭제 기능이 존재해야함
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:http/http.dart' as http;

class MakePath extends StatefulWidget {
  final int targetTime;
  final Position currentPosition;
  const MakePath({
    required this.targetTime,
    required this.currentPosition,
    super.key,
  });

  @override
  State<MakePath> createState() => _MakePathState();
}

class _MakePathState extends State<MakePath> {
  late BitmapDescriptor red_marker;
  late BitmapDescriptor blue_marker;
  late GoogleMapController mapController;
  late Position currentPosition;
  Set<Marker> startClosewayPoints = {};
  Set<Marker> endClosewayPoints = {};
  CameraPosition? currentCameraPosition;
  int currentMarkerIndex = 0;

  // Set<Marker> markers = {};

  @override
  initState() {
    super.initState();
    setRedMarker();
    setBlueMarker();
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
                target:
                    LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
                zoom: 14.0,
              ),
              markers: startClosewayPoints.union(endClosewayPoints),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_left)),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _makeRequest(widget.targetTime, widget.currentPosition,
                              startClosewayPoints, endClosewayPoints);
                        });
                      },
                      child: Text('경로 검색'),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Image.asset('asset/image/cross_hair.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: startWayPointAdd,
                      child: Text('경유지 추가'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startClosewayPoints.clear();
                          endClosewayPoints.clear();
                        });
                      },
                      child: Icon(Icons.delete),
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

  Future<void> setBlueMarker() async {
    blue_marker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'asset/image/blue_marker.png',
    );
  }

  Future<void> setRedMarker() async {
    red_marker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'asset/image/red_marker.png',
    );
  }

  void startWayPointAdd() {
    final LatLng center = currentCameraPosition!.target;
    final markerId = MarkerId(center.toString());
    setState(
      () {
        startClosewayPoints.add(
          Marker(
            markerId: markerId,
            position: center,
            icon: red_marker,
            infoWindow: InfoWindow(
              title: '경유지',
              snippet: '탭하여 삭제',
              onTap: () {
                showWayPointDialog(markerId, red_marker);
              },
            ),
          ),
        );
        currentMarkerIndex = startClosewayPoints.length - 1;
      },
    );
  }

  void endWayPointAdd() {
    final LatLng center = currentCameraPosition!.target;
    final markerId = MarkerId(center.toString());
    setState(
      () {
        endClosewayPoints.add(
          Marker(
            markerId: markerId,
            position: center,
            icon: blue_marker,
            infoWindow: InfoWindow(
              title: '경유지',
              snippet: '탭하여 수정',
              onTap: () {
                showWayPointDialog(markerId, blue_marker);
              },
            ),
          ),
        );
        currentMarkerIndex = endClosewayPoints.length - 1;
      },
    );
  }

  void _removeRedMarker(MarkerId markerId) {
    setState(
      () {
        startClosewayPoints
            .removeWhere((marker) => marker.markerId == markerId);
        if (currentMarkerIndex >= startClosewayPoints.length) {
          currentMarkerIndex = startClosewayPoints.length - 1;
        }
      },
    );
  }

  void _removeBlueMarker(MarkerId markerId) {
    setState(
      () {
        startClosewayPoints
            .removeWhere((marker) => marker.markerId == markerId);
        if (currentMarkerIndex >= endClosewayPoints.length) {
          currentMarkerIndex = endClosewayPoints.length - 1;
        }
      },
    );
  }

  void showWayPointDialog(MarkerId markerId, BitmapDescriptor icon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경유지 추가'),
          content: Text('경유지를 추가할 위치를 선택해주세요'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _removeRedMarker(markerId);
                startWayPointAdd();
                Navigator.pop(context);
              },
              child: Text('가는길'),
            ),
            ElevatedButton(
              onPressed: () {
                _removeBlueMarker(markerId);
                endWayPointAdd();
                Navigator.pop(context);
              },
              child: Text('오는길'),
            ),
            ElevatedButton(
              onPressed: () {
                if (icon == red_marker) {
                  _removeRedMarker(markerId);
                } else {
                  _removeBlueMarker(markerId);
                }
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    currentCameraPosition = position;
  }

  void _makeRequest(int totalSec, Position currentPosition,
      Set<Marker> redMarker, Set<Marker> blueMarker) async {
    final url = 'https://dev.mamasteps.dev/api/v1/routes/computeRoutes';
    final AccessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    List<Coordinate> redMarker = convertMarkersToList(startClosewayPoints);
    List<Coordinate> blueMarker = convertMarkersToList(endClosewayPoints);

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
        Navigator.pop(context, response.body);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleLogin(),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      print('Error sending POST request: $error');
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

// void _goToNextMarker() {
//   if (markers.isNotEmpty) {
//     setState(() {
//       currentMarkerIndex = (currentMarkerIndex + 1) % markers.length;
//     });
//     final Marker nextmarker = markers.elementAt(currentMarkerIndex);
//     mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: nextmarker.position,
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }
// }
//
// void _goToPrevMarker() {
//   if (markers.isNotEmpty) {
//     setState(() {
//       currentMarkerIndex =
//           (currentMarkerIndex - 1 + markers.length) % markers.length;
//     });
//     final Marker prevMarker = markers.elementAt(currentMarkerIndex);
//     mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: prevMarker.position,
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }
// }