import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

drawMarkers(Set<Marker> markers,List<LatLng> resultList) async {
  markers.clear();

  markers.add(
    Marker(
      markerId: MarkerId("origin"),
      visible: true,
      icon: BitmapDescriptor.defaultMarker,
      position: resultList[0],
    ),
  );
  markers.add(
    Marker(
      markerId: MarkerId("destination"),
      icon: BitmapDescriptor.defaultMarker,
      position: resultList[resultList.length - 1],
    ),
  );
}