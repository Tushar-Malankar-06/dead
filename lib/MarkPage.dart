import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'location.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';
import 'HomeScreen.dart';

class MarkPage extends StatefulWidget {
  const MarkPage({Key? key}) : super(key: key);

  @override
  State<MarkPage> createState() => _MarkPageState();
}

class _MarkPageState extends State<MarkPage> {
  String getTime() {
    String formattedTime;
    DateTime now = DateTime.now();
    formattedTime = DateFormat('kk:mm:ss').format(now);
    return formattedTime;
  }

  String getDay() {
    String formattedDate;
    DateTime now = DateTime.now();
    formattedDate = DateFormat('EEE d MMM').format(now);
    return formattedDate;
  }

  Future<String> gettLocation() async {
    Position position1 = await determinePosition();
    return position1.toString();
  }

  int _checkin = 0;
  String checkIn_time = "--/--/--";
  String checkOut_time = "--/--/--";
  late Position position;

  void checkIn(int checkin) {
    _checkin = checkin;
    if (_checkin == 1) {
      setState(() {
        checkIn_time = getTime();
        gettLocation();
        print(position.toString());
        print(position);
      });
    } else if (_checkin == 2) {
      setState(() {
        checkOut_time = getTime();
        gettLocation();
        print(position.toString());
        print(position);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CheckIn/Out"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Text(
              getDay(),
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 50.0),
            ),
          ),
          OutlinedButton(
              onPressed: () {
                checkIn(1);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 100.0),
              ),
              child: Text("Check In")),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Check In",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(
                width: 80,
                child: Divider(),
              ),
              Text(
                checkIn_time,
                style: const TextStyle(fontSize: 25),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: OutlinedButton(
                onPressed: () {
                  checkIn(2);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red,
                  ),
                ),
                child: Text("Check Out")),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Check OUT",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(
                width: 80,
                child: Divider(),
              ),
              Text(
                checkOut_time,
                style: const TextStyle(fontSize: 25),
              ),
              Text(
                "CHECK IN",
                style: const TextStyle(fontSize: 25),
              )
            ],
          )
        ],
      ),
    );
  }
}
