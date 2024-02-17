import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamasteps_frontend/map/component/util/get_position.dart';
import 'package:mamasteps_frontend/map/screen/map_page_body.dart';
import 'package:mamasteps_frontend/map/screen/map_page_header.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;

import 'package:mamasteps_frontend/login/widget/google_login_components.dart';
import 'package:mamasteps_frontend/map/component/google_map/pointlatlng_to_latlng.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';
import 'package:mamasteps_frontend/map/screen/make_path.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';
import 'package:mamasteps_frontend/map/screen/tracking_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';
import 'package:mamasteps_frontend/map/model/route_model.dart';
import 'package:mamasteps_frontend/map/component/util/map_server_communication.dart';

bool check = false;
final List<String> resultsString = [
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
  '{wqcFov`dW??RFXHDBb@L????YbB????l@T????RF????AFu@xDSbB????DB????EC????RcBt@yD@G????SG????m@U????XcB????c@MECYISG??',
];

class MapPage extends StatefulWidget {

  const MapPage({super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final pageController = PageController(viewportFraction: 0.877);
  double currentPage = 0;
  int currentHour = 0;
  int currentMin = 0;
  int currentSec = 0;
  int totalSec = 0;
  Set<Marker> startClosewayPoints = {};
  Set<Marker> endClosewayPoints = {};
  late Position currentPosition;

  RequestData requestData = RequestData(
    targetTime: 0,
    origin: Coordinate(latitude: 0, longitude: 0),
    startCloseIntermediates: [],
    endCloseIntermediates: [],
  );

  ApiResponse apiResponse = ApiResponse(
    isSuccess: false,
    code: '',
    message: '',
    result: [],
  );

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toDouble();
      });
    });
    getInitPosition().then((value) {
      setState(() {
        currentPosition = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
            Header(),
            Body(
                currentHour: currentHour,
                currentMin: currentMin,
                currentSec: currentSec,
                onHourChanged: onHourChanged,
                onMinChanged: onMinChanged,
                onSecChanged: onSecChanged,
                apiResponse: apiResponse,
                endClosewayPoints: endClosewayPoints,
                startClosewayPoints: startClosewayPoints,
                pageController: pageController,
                currentPosition: currentPosition,
                callBack: acceptResponse,
                makeRequest: makeRequest),
          ],
        ),
      ),
    );
  }

  void onHourChanged(value) {
    setState(() {
      currentHour = value;
    });
  }

  void onMinChanged(value) {
    setState(() {
      currentMin = value;
    });
  }

  void onSecChanged(value) {
    setState(() {
      currentSec = value;
    });
  }

  void serverToClientTimeConvert(value) {
    setState(() {
      totalSec = value;
      currentHour = value ~/ 3600;
      currentMin = (value % 3600) ~/ 60;
      currentSec = value % 60;
    });
  }

  void clientToServerTimeConvert() {
    setState(() {
      totalSec += currentHour * 3600;
      totalSec += currentMin * 60;
      totalSec += currentSec;
    });
  }

  void acceptResponse(value) {
    setState(() {
      apiResponse = ApiResponse.fromJson(value);
      if (apiResponse.isSuccess) {
        final List<String> results =
            apiResponse.result.map((route) => route.polyLine).toList();
      } else {
        print('Server Error');
      }
    });
  }

  List<Coordinate> convertMarkersToList(Set<Marker> markers) {
    return markers.map((marker) {
      return Coordinate(
        latitude: marker.position.latitude,
        longitude: marker.position.longitude,
      );
    }).toList();
  }
}
