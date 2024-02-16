class RequestData {
  final int targetTime;
  final Coordinate origin;
  final List<Coordinate> startCloseIntermediates;
  final List<Coordinate> endCloseIntermediates;

  RequestData({
    required this.targetTime,
    required this.origin,
    required this.startCloseIntermediates,
    required this.endCloseIntermediates,
  });

  Map<String, dynamic> toJson() => {
    'targetTime': targetTime,
    'origin': origin.toJson(),
    'startCloseIntermediates':
    startCloseIntermediates.map((i) => i.toJson()).toList(),
    'endCloseIntermediates':
    endCloseIntermediates.map((i) => i.toJson()).toList(),
  };
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class ApiResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<Route> result;

  ApiResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    isSuccess: json['isSuccess'],
    code: json['code'],
    message: json['message'],
    result: List<Route>.from(json['result'].map((x) => Route.fromJson(x))),
  );
}

class Route {
  final int routeId;
  final int routesProfileId;
  final CreatedWaypoint createdWaypoint;
  final String polyLine;
  final int totalDistanceMeters;
  final int totalTimeSeconds;
  final String createdAt;
  final String updatedAt;

  Route({
    required this.routeId,
    required this.routesProfileId,
    required this.createdWaypoint,
    required this.polyLine,
    required this.totalDistanceMeters,
    required this.totalTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) => Route(
    routeId: json['routeId'],
    routesProfileId: json['routesProfileId'],
    createdWaypoint: CreatedWaypoint.fromJson(json['createdWaypoint']),
    polyLine: json['polyLine'],
    totalDistanceMeters: json['totalDistanceMeters'],
    totalTimeSeconds: json['totalTimeSeconds'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );
}

class CreatedWaypoint {
  final double latitude;
  final double longitude;

  CreatedWaypoint({
    required this.latitude,
    required this.longitude,
  });

  factory CreatedWaypoint.fromJson(Map<String, dynamic> json) =>
      CreatedWaypoint(
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
      );
}