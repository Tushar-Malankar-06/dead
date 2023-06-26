import 'dart:math';
import 'dart:math';

import 'package:autheticationscreen/HomePage.dart';

const double earthRadius = 6371; // Earth's radius in kilometers

double degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

bool isInsideGeofence(double centerLat, double centerLon, double pointLat,
    double pointLon, double radiusInMeters) {
  double dLat = degreesToRadians(pointLat - centerLat);
  double dLon = degreesToRadians(pointLon - centerLon);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(degreesToRadians(centerLat)) *
          cos(degreesToRadians(pointLat)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c * 1000; // Convert distance to meters
  SecondPage.exporter.distance = distance.toString();
  return distance <= radiusInMeters;
}

bool checkLoc(lat2, lon2) {
  double centerLatitude = 19.1462019; // Center point latitude (e.g., Berlin)
  double centerLongitude = 72.8017458; // Center point longitude (e.g., Berlin)
  double testLatitude = lat2; // Test point latitude
  double testLongitude = lon2; // Test point longitude
  double radiusInMeters = 500.0; // Radius in meters

  bool isInside = isInsideGeofence(centerLatitude, centerLongitude,
      testLatitude, testLongitude, radiusInMeters);

  return isInside;
}

class CalcDistance {
  double earthRadius = 6371; // Earth's radius in kilometers

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2,
      {bool inKilometers = true}) {
    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    if (!inKilometers) {
      distance *= 1000; // Convert to meters
    }

    return distance;
  }

  double distancecalc(latitude2, longitude2) {
    double latitude1 = 19.1462019; // Berlin
    double longitude1 = 72.8017458;

    double distanceInKm =
        calculateDistance(latitude1, longitude1, latitude2, longitude2);
    print('Distance in kilometers: $distanceInKm');

    double distanceInMeters = calculateDistance(
        latitude1, longitude1, latitude2, longitude2,
        inKilometers: false);
    print('Distance in meters: $distanceInMeters');

    var distanceInMeters1 = sqrt(
        (latitude2 - latitude1) * (latitude2 - latitude1) +
            (longitude2 - longitude1) * (longitude2 - longitude1));
    return distanceInMeters;
  }
}
