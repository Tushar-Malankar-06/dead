import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

Position? _position;

Future<Position> determinePosition() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location Permissions are denied');
    }
  }

  return await Geolocator.getCurrentPosition();
}
