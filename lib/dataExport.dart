import 'package:autheticationscreen/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class Exporter {
  String uid;
  String name;
  String email;
  String movement;
  String longitute;
  String latitude;
  String distance;
  String date;
  String time;
  String sta;
  String faceauth;

  /// Constructs a Category.
  Exporter(
      {required this.uid,
      required this.name,
      required this.email,
      required this.movement,
      required this.longitute,
      required this.latitude,
      required this.distance,
      required this.date,
      required this.time,
      required this.sta,
      required this.faceauth});

  factory Exporter.fromJson(dynamic json) {
    return Exporter(
        uid: "${json['uid']}",
        name: "${json['name']}",
        email: "${json['email']}",
        movement: "${json['movement']}",
        latitude: "${json['latitude']}",
        longitute: "${json['longitute']}",
        distance: "${json['distance']}",
        time: "${json['time']}",
        date: "${json['date']}",
        sta: "${json['sta']}",
        faceauth: "${json["faceauth"]}");
  }

  // Method to make GET parameters.
  Map toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'movement': movement,
        'latitude': latitude,
        'longitude': longitute,
        'distance': distance,
        'time': time,
        'date': date,
        'sta': sta,
        'faceauth': faceauth
      };
}

Uri URL = Uri.parse(
    'https://script.google.com/macros/s/AKfycbwmtAN8DhXM4adF8nt3bB_eiZNPQQBpdDI3xS71mNU4A6OL4j3MqHrptPe2nk5AmoAq/exec');

// Success Status Message
const STATUS_SUCCESS = "SUCCESS";
void submitForm(Exporter feedbackForm, void Function(String) callback) async {
  try {
    await http.post(URL, body: feedbackForm.toJson()).then((response) async {
      print(response.body);
      if (response.statusCode == 302) {
        var url = Uri.parse(response.headers['location']!);
        await http.get(url).then((response) {
          callback(convert.jsonDecode(response.body)['status']);
          if (response.body == "success") {}
        });
      } else {
        callback(convert.jsonDecode(response.body)['status']);
      }
    });
  } catch (e) {
    print(e);
  }
}

void saveCheckInAndOutTime() async {
  try {
    print("entered");
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("QS", "enabled");
    pref.setString("CI/C0", SecondPage.exporter.movement);
    pref.setString("Date", SecondPage.exporter.date);
    pref.setString("Time", SecondPage.exporter.time);
    print("done");
  } catch (e) {
    print("Exception while storing preferences: $e");
    // Handle the exception or display an error message as needed
  }
}
