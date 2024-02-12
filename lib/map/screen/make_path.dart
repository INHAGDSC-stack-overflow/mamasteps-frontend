import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';

final List<PointLatLng> results = PolylinePoints().decodePolyline(
    '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??');

class MakePath extends StatefulWidget {
  const MakePath({
    super.key,
  });

  @override
  State<MakePath> createState() => _MakePathState();
}

class _MakePathState extends State<MakePath> {
  late GoogleMapController mapController;
  List<LatLng> resultList = PointToLatLng(results);
  CameraPosition? currentCameraPosition;
  int currentMarkerIndex = 0;

  Set<Marker> markers = {};
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
              markers: markers,
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
                      onPressed: () {
                        Navigator.pop(
                          context,
                          markers,
                        );
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
                    ElevatedButton(
                      onPressed: _goToPrevMarker,
                      child: Icon(Icons.arrow_left),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _addWayPoint,
                      child: Text('경유지 추가'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _goToNextMarker,
                      child: Icon(Icons.arrow_right),
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

  void _addWayPoint() {
    final LatLng center = currentCameraPosition!.target;
    final markerId = MarkerId(center.toString());
    setState(
      () {
        markers.add(
          Marker(
            markerId: markerId,
            position: center,
            infoWindow: InfoWindow(
                title: '경유지',
                snippet: '탭하여 삭제',
                onTap: () {
                  _removeMarker(markerId);
                }),
          ),
        );
        currentMarkerIndex = markers.length - 1;
      },
    );
  }

  void _removeMarker(MarkerId markerId) {
    setState(
      () {
        markers.removeWhere((marker) => marker.markerId == markerId);
        if (currentMarkerIndex >= markers.length) {
          currentMarkerIndex = markers.length - 1;
        }
      },
    );
  }

  void _goToNextMarker() {
    if (markers.isNotEmpty) {
      setState(() {
        currentMarkerIndex = (currentMarkerIndex + 1) % markers.length;
      });
      final Marker nextmarker = markers.elementAt(currentMarkerIndex);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: nextmarker.position,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _goToPrevMarker() {
    if (markers.isNotEmpty) {
      setState(() {
        currentMarkerIndex =
            (currentMarkerIndex - 1 + markers.length) % markers.length;
      });
      final Marker prevMarker = markers.elementAt(currentMarkerIndex);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: prevMarker.position,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    currentCameraPosition = position;
  }
}
