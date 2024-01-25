// class RouteModel{
//   final List<Coordinates> coordinates;
//   final double totalTimeSeconds;
//   final double totalDistanceMeters;
//
//   RouteModel({
//     required this.coordinates,
//     required this.totalTimeSeconds,
//     required this.totalDistanceMeters,
//   });
// }
//
// class Coordinates{
//   final double latitude;
//   final double longitude;
//
//   Coordinates({
//     required this.latitude,
//     required this.longitude,
//   });
// }

class RouteModel {
  final String Encoded_Polyline;
  final double totalTimeSeconds;
  final double totalDistanceMeters;

  RouteModel({
    required this.Encoded_Polyline,
    required this.totalTimeSeconds,
    required this.totalDistanceMeters,
  });
}
