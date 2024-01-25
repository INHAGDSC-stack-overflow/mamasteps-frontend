import 'package:geolocator/geolocator.dart';
import 'package:google_map_proj/component/geolocator/geolocator_getlocation.dart';
import 'package:google_map_proj/component/geolocator/geolocator_getpermission.dart';

void SetPermissionandLocation(originlatitude, originlongitude) {
  Future<bool> permission = determinePermission();
  if(permission == true){
    Future<Position> position = getPosition();
    position.then((value) {
      originlatitude = value.latitude;
      originlongitude = value.longitude;
    });
  }
}