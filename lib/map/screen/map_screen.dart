import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawpolyline.dart';
import 'package:mamasteps_frontend/map/component/google_map/drawmarker.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';

class MapScreen extends StatefulWidget {
  // final List<List<PointLatLng>> results;
  final String Path;
  const MapScreen({super.key,
  // required this.results,
    required this.Path,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
}

// void _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future.value('위치 서비스가 비활성화되어 있습니다.');
//   }
//   permission = await Geolocator.checkPermission();
//   if(permission == LocationPermission.denied){
//     permission = await Geolocator.requestPermission();
//     if(permission == LocationPermission.denied){
//       return Future.value('위치 권한이 거부되었습니다.');
//     }
//   }
//   if(permission == LocationPermission.deniedForever){
//     return Future.error('위치 권한이 영구적으로 거부되었습니다, 설정에서 변경해주세요.');
//   }
//
//   Geolocator.getPositionStream().listen(
//         (Position position){
//       print(position);
//     },
//     onError: (e){
//       print(e);
//     },
//   );
// }