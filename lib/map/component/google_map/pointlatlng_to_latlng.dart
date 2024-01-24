import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

List<LatLng> PointToLatLng (List<PointLatLng> input) {
  final List<LatLng> resultList = input.map((point) {
    return LatLng(point.latitude, point.longitude);
  }).toList();
  return resultList;
}