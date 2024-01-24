class RouteModel{
  final List<Coordinates> coordinates;
  final double totalTimeSeconds;
  final double totalDistanceMeters;

  RouteModel({
    required this.coordinates,
    required this.totalTimeSeconds,
    required this.totalDistanceMeters,
  });
}

class Coordinates{
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });
}