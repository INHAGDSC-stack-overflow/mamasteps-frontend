import 'package:google_maps_flutter/google_maps_flutter.dart';

//새롭게 경로와 마커를 그릴 때 마다 기존의 경로와 마커를 지우고 새것을 생성함
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