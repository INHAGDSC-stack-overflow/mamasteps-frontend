import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapType { normal, satellite, terrain, hybrid }

class InitCameraPositionModel {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final MapType mapType;
  final bool zoomGesturesEnabled;
  final bool zoomControlsEnabled;
  final Set<Polyline> polylines;

  InitCameraPositionModel({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.myLocationEnabled,
    required this.myLocationButtonEnabled,
    required this.mapType,
    required this.zoomGesturesEnabled,
    required this.zoomControlsEnabled,
    required this.polylines,
  });
}