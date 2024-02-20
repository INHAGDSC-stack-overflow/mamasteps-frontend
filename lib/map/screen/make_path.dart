/*
  - 사용자가 경로를 설정하는 화면
  - 사용자가 경유지를 설정할 수 있음
  - 경유지는 startClose, endClose로 구분
  - 경로 검색을 누를 시 서버에 시간과 경유지 정보를 넘기며 요청을 전송해야 함
  - undo 기능과(보류) 경유지 전체 삭제 기능이 존재해야함
*/

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MakePath extends StatefulWidget {
  final int targetTime;
  final Position currentPosition;
  final Set<Marker> startClosewayPoints;
  final Set<Marker> endClosewayPoints;
  // final void Function(Function(String), BuildContext) makeRequest;
  final VoidCallback makeRequest;
  // final void callback;
  // final VoidCallback onCheckChange;
  const MakePath({
    required this.targetTime,
    required this.currentPosition,
    required this.startClosewayPoints,
    required this.endClosewayPoints,
    required this.makeRequest,
    // required this.callback,
    // required this.onCheckChange,
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
              markers: widget.startClosewayPoints.union(widget.endClosewayPoints),
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
                      // onPressed: () {
                      //   setState(() {
                      //     widget.makeRequest(
                      //       (String response) {
                      //         widget.callback(response);
                      //       },
                      //       context,
                      //     );
                      //   });
                      // },
                      onPressed: () {
                        widget.makeRequest();
                        Navigator.pop(context);
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
                          widget.startClosewayPoints.clear();
                          widget.endClosewayPoints.clear();
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
        widget.startClosewayPoints.add(
          Marker(
            markerId: markerId,
            position: center,
            icon: red_marker,
            infoWindow: InfoWindow(
              title: '경유지',
              snippet: '탭하여 수정',
              onTap: () {
                showWayPointDialog(markerId, red_marker);
              },
            ),
          ),
        );
        currentMarkerIndex = widget.startClosewayPoints.length - 1;
      },
    );
  }

  void endWayPointAdd() {
    final LatLng center = currentCameraPosition!.target;
    final markerId = MarkerId(center.toString());
    setState(
      () {
        widget.endClosewayPoints.add(
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
        currentMarkerIndex = widget.endClosewayPoints.length - 1;
      },
    );
  }

  void _removeRedMarker(MarkerId markerId) {
    setState(
      () {
        widget.startClosewayPoints
            .removeWhere((marker) => marker.markerId == markerId);
        if (currentMarkerIndex >= widget.startClosewayPoints.length) {
          currentMarkerIndex = widget.startClosewayPoints.length - 1;
        }
      },
    );
  }

  void _removeBlueMarker(MarkerId markerId) {
    setState(
      () {
        widget.endClosewayPoints
            .removeWhere((marker) => marker.markerId == markerId);
        if (currentMarkerIndex >= widget.endClosewayPoints.length) {
          currentMarkerIndex = widget.endClosewayPoints.length - 1;
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
                setState(() {
                  _removeRedMarker(markerId);
                  startWayPointAdd();
                });
                Navigator.pop(context);
              },
              child: Text('가는길'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _removeBlueMarker(markerId);
                  endWayPointAdd();
                });
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
}


// import 'package:mamasteps_frontend/login/screen/login_page.dart';
// import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
// import 'package:mamasteps_frontend/map/screen/map_screen.dart';
// import 'package:mamasteps_frontend/storage/login/login_data.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'dart:convert';