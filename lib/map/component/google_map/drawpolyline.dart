import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//새롭게 경로와 마커를 그릴 때 마다 기존의 경로와 마커를 지우고 새것을 생성함
drawPolylines(Set<Polyline> polylines, List<LatLng> resultList) async {
  polylines.clear();

  polylines.add(
    Polyline(
      polylineId: PolylineId(
        resultList[0].toString(),
      ),
      visible: true,
      width: 5,
      points: resultList,
      color: Colors.blue,
      patterns: [PatternItem.dash(20), PatternItem.gap(20)],
    ),
  );
}