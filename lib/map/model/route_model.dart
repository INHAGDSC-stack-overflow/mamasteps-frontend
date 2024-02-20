class RequestData {
  final int targetTime;
  final int walkSpeed;
  final Coordinate origin;
  final List<Coordinate> startCloseWaypoints;
  final List<Coordinate> endCloseWaypoints;
  final String createdAt;
  final String updatedAt;

  RequestData({
    required this.targetTime,
    required this.walkSpeed,
    required this.origin,
    required this.startCloseWaypoints,
    required this.endCloseWaypoints,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'targetTime': targetTime,
    'walkSpeed': walkSpeed,
    'origin': origin.toJson(),
    'startCloseWaypoints':
    startCloseWaypoints.map((i) => i.toJson()).toList(),
    'endCloseWaypoints':
    endCloseWaypoints.map((i) => i.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// class RequestData {
//   final int targetTime;
//   final Coordinate origin;
//   final List<Coordinate> startCloseIntermediates;
//   final List<Coordinate> endCloseIntermediates;
//
//   RequestData({
//     required this.targetTime,
//     required this.origin,
//     required this.startCloseIntermediates,
//     required this.endCloseIntermediates,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'targetTime': targetTime,
//     'origin': origin.toJson(),
//     'startCloseIntermediates':
//     startCloseIntermediates.map((i) => i.toJson()).toList(),
//     'endCloseIntermediates':
//     endCloseIntermediates.map((i) => i.toJson()).toList(),
//   };
// }

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
  final List<MadeRoute> result;

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
    result: List<MadeRoute>.from(json['result'].map((x) => MadeRoute.fromJson(x))),
  );
}

class MadeRoute {
  final String polyLine;
  final double totalDistanceMeters;
  final int totalTimeSeconds;
  final String createdAt;


  MadeRoute({
    required this.polyLine,
    required this.totalDistanceMeters,
    required this.totalTimeSeconds,
    required this.createdAt,
  });

  factory MadeRoute.fromJson(Map<String, dynamic> json) => MadeRoute(
    polyLine: json['polyLine'],
    totalDistanceMeters: json['totalDistanceMeters'],
    totalTimeSeconds: json['totalTimeSeconds'],
    createdAt: json['createdAt'],
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