import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';

//서버로부터 받은 polyline을 decode한 결과, 더미 데이터
final List<PointLatLng> results = PolylinePoints().decodePolyline(
    '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??');

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  //polyline들의 집합
  Set<Polyline> polylines = {};
  //marker들의 집합
  Set<Marker> markers = {};
  List<LatLng> resultList = PointToLatLng(results);

  @override
  void initState() {
    //getinformation();
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
  Widget build(BuildContext context) {
    return GoogleMap(
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
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.value('위치 권한이 거부되었습니다.');
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error('위치 권한이 영구적으로 거부되었습니다, 설정에서 변경해주세요.');
    }

    Geolocator.getPositionStream().listen(
        (Position position){
          print(position);
        },
      onError: (e){
          print(e);
      },
    );
  }
}