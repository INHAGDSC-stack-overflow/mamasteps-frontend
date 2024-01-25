import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// PointLatLng 형식의 리스트 results를 LatLng 형식의 리스트로 변환
List<LatLng> PointToLatLng (List<PointLatLng> input) {
  final List<LatLng> resultList = input.map((point) {
    return LatLng(point.latitude, point.longitude);
  }).toList();
  return resultList;
}