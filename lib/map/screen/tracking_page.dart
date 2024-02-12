import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';

class TrackingScreen extends StatefulWidget {
  // final List<List<PointLatLng>> results;
  final String Path;
  final int hour;
  final int minute;
  final int second;
  const TrackingScreen({
    super.key,
    // required this.results,
    required this.Path,
    required this.hour,
    required this.minute,
    required this.second,
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
  //polyline들의 집합
  Set<Polyline> polylines = {};
  //marker들의 집합
  Set<Marker> markers = {};
  late List<LatLng> resultList;

  @override
  void initState() {
    //getinformation();
    List<PointLatLng> results = PolylinePoints().decodePolyline(widget.Path);
    resultList = PointToLatLng(results);
    drawPolylines(polylines, resultList);
    drawMarkers(markers, resultList);
    //_determinePosition();
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
              markers: markers,
              mapType: MapType.normal,
              onMapCreated: (controller) {
                setState(
                  () {
                    mapController = controller;
                  },
                );
              },
            ),
            _watch(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    FloatingActionButton(
                      onPressed: (){
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

  Widget _watch(){
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('00',style: TextStyle(fontSize: 80),),//시
              const SizedBox(width: 10),
              Text(':',style: TextStyle(fontSize: 80),),
              const SizedBox(width: 10),
              Text('00',style: TextStyle(fontSize: 80),),//분
              const SizedBox(width: 10),
              Text(':',style: TextStyle(fontSize: 80),),
              const SizedBox(width: 10),
              Text('99',style: TextStyle(fontSize: 80),),//초
            ],
          ),
        ),
      ),
    );
  }

  void _onClick(){
    if(icon==Icons.play_arrow){
      icon = Icons.pause;
      color = Colors.grey;
    }
    else{
      icon = Icons.play_arrow;
      color = Colors.blue;
    }
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

    Geolocator.getPositionStream().listen(
      (Position position) {
        print(position);
      },
      onError: (e) {
        print(e);
      },
    );
  }
}


