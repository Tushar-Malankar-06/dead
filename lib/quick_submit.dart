import 'package:autheticationscreen/PunchPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'distance_get.dart';
import 'get_time.dart';
import 'ver_location.dart';
import 'RecognitionScreen.dart';
import 'PunchPage.dart';

class QuickSubmit {
  void QuickLocation(BuildContext context) async {
    Position? position;
    double latitude2;
    double longitude2;
    double stalatitude = 19.1462019;
    double stalongitude = 72.8017458;
    double req_distance = 1000;

    Position position1 = await determinePosition();
    bool a = true;
    position = position1;
    latitude2 = position1.latitude;
    longitude2 = position1.longitude;
    String time = await getTime().setup(false);
    String date = await getTime().setup(true);

    a = checkLoc(latitude2, longitude2);
    if (a == true) {
      SecondPage.exporter.latitude = latitude2.toString();
      SecondPage.exporter.longitute = longitude2.toString();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RecognitionScreen()));
    } else {
      final snackBar = SnackBar(
        content: Text('You are outside campus'),
        duration: Duration(seconds: 5), // Adjust the duration as needed
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    ;
  }

//String decideMovement() {}
}
