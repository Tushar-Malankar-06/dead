import 'package:autheticationscreen/HomePage.dart';
import 'package:autheticationscreen/HomeScreen.dart';
import 'package:autheticationscreen/RecognitionScreen.dart';
import 'package:autheticationscreen/dataExport.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'form.dart';
import 'ver_location.dart';
import 'distance_get.dart';
import 'package:geolocator/geolocator.dart';
import 'get_time.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class RadioExampleApp extends StatelessWidget {
  const RadioExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mark Attendance'),
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 25, 63, 92),
          centerTitle: true,
          actions: [Icon(Icons.help)],
        ),
        body: const Center(
          child: PunchPage(),
        ),
      ),
    );
  }
}

enum SingingCharacter { CHECKIN, CHECKOUT }

class PunchPage extends StatefulWidget {
  const PunchPage({super.key});

  @override
  State<PunchPage> createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> {
  SingingCharacter? _character = SingingCharacter.CHECKIN;
  String ciStatus = "PENDING";
  String coStatus = "PENDING";
  bool button_stat = false;
  bool flag = false;
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Cancel booking'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(req_distance.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Position? position;
  late double latitude2;
  late double longitude2;
  double stalatitude = 19.1462019;
  double stalongitude = 72.8017458;
  double req_distance = 1000;

  void _getCurrentLocation() async {
    Position position1 = await determinePosition();
    bool a = true;
    position = position1;
    latitude2 = position1.latitude;
    longitude2 = position1.longitude;
    String time = await getTime().setup(false);
    String date = await getTime().setup(true);

    a = checkLoc(latitude2, longitude2);

    setState(() {
      if (a == true) {
        SecondPage.exporter.latitude = latitude2.toString();
        SecondPage.exporter.longitute = longitude2.toString();
        SecondPage.exporter.date = date;
        SecondPage.exporter.time = time;
        SecondPage.exporter.movement = _character.toString().split(".").last;

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const RecognitionScreen()));
      } else {
        final snackBar = SnackBar(
          content: Text('You are outside campus'),
          duration: Duration(seconds: 5), // Adjust the duration as needed
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print("Hello");
    getStatusList(SecondPage.exporter.email, context);
    //here is the async code, you can execute any async code here
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Status'),
        leading: Icon(Icons.help),
      ),
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ciStatus == "PENDING"
                      ? ListTile(
                          title: Text(
                            "CHECK IN",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          leading: Radio<SingingCharacter>(
                            value: SingingCharacter.CHECKIN,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        )
                      : ListTile(
                          leading: Icon(Icons.check, color: Colors.green),
                          title: Text(
                            'CHECK IN DONE FOR TODAY',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  ListControl(),
                  SizedBox(
                    height: 35.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Today's Date",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                                child: Divider(),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(DateTime.now()),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Time",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                                child: Divider(),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  // Replace 'liveTime' with the actual live time variable
                                  DateFormat('HH:mm:ss').format(DateTime.now()),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Check In",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                width: 80,
                                child: Divider(),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  flag != false ? ciStatus : "CHECKING",
                                  style: ciStatus == "DONE"
                                      ? TextStyle(
                                          fontSize: 20, color: Colors.green)
                                      : TextStyle(
                                          fontSize: 20, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Check Out",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                width: 80,
                                child: Divider(),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  flag != false ? coStatus : "CHECKING",
                                  style: coStatus == "DONE"
                                      ? TextStyle(
                                          fontSize: 20, color: Colors.green)
                                      : TextStyle(
                                          fontSize: 20, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                    child: Divider(),
                  ),
                  SizedBox(height: 100.0),
                  Material(
                    color: Colors.deepOrangeAccent,
                    borderRadius: BorderRadius.circular(50),
                    child: button_stat == true
                        ? InkWell(
                            onTap: () async {
                              if (flag == true) {
                                _getCurrentLocation();
                              } else {
                                final snackBar = SnackBar(
                                  content: Text('WAIT'),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 200,
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                'Proceed to Next Step',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Go Back",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getStatusList(String email, BuildContext context) async {
    // Success Status Message
    flag = false;
    button_stat = false;
    var STATUS_SUCCESS = "SUCCESS";
    print(email);
    final baseUrl =
        'https://script.google.com/macros/s/AKfycbwmtAN8DhXM4adF8nt3bB_eiZNPQQBpdDI3xS71mNU4A6OL4j3MqHrptPe2nk5AmoAq/exec';
    // final baseUrl =
    //     'https://script.google.com/macros/s/AKfycbzo9qy9JhLx9nOOz1tcPcllvNIE_o7e-e7DiF68OHvV13N7YwJAVaCxfOxg8m4lsZ4KIw/exec';

    String date = await getTime().setup(true);
    final url = Uri.parse(baseUrl + '?email=$email&date=$date');
    // final url = Uri.parse(baseUrl);
    print(date);
    // final url = Uri.parse(baseUrl + '?email=$email');
    print(email);
    final response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List jsonFeedback = convert.jsonDecode(response.body) as List;
      jsonFeedback.map((json) => FeedbackForm.fromJson(json)).toList();
      print("error here 200");
      coStatus = "PENDING";
      ciStatus = "PENDING";
      if (jsonFeedback.isEmpty) {
        print("Nothing done today");
        setState(() {
          ciStatus = "PENDING";
          coStatus = "PENDING";
          setState(() {
            flag = true;
          });
        });
      } else {
        print("error happened her");
        for (int i = 0; i < jsonFeedback.length; i++) {
          var json = Exporter.fromJson(jsonFeedback[i]);
          print("false from here");

          if (json.movement == "CHECKIN" && coStatus == "PENDING") {
            print("CHECK IS DONE");
            print(coStatus);
            print(ciStatus);
            setState(() {
              ciStatus = "DONE";
              coStatus = "PENDING";
              flag = true;
              button_stat = true;
            });
          } else if (json.movement == "CHECKIN" && coStatus == "DONE") {
            print(coStatus);
            print(ciStatus);
            print("CHECK IS DONE");
            setState(() {
              ciStatus = "DONE";
              coStatus = "DONE";
              //coStatus = "PENDING";
              flag = true;
            });
          } else if (json.movement == "CHECKOUT") {
            print(coStatus);
            print(ciStatus);
            print("CHECK OUT DONE");
            setState(() {
              button_stat = false;
              ciStatus = "DONE";
              coStatus = "DONE";
              flag = true;
            });
          } else {
            print(coStatus);
            print(ciStatus);
            print("Entering here");
            setState(() {
              button_stat = true;
              coStatus = "PENDING";
              ciStatus = "PENDING";
              flag = true;
            });
          }
        }
      }
    } else {
      throw Exception('Failed to retrieve feedback list');
    }
    if (ciStatus == "DONE" && coStatus == "DONE") {
      button_stat = false;
      flag = true;
    }
  }

  Widget ListControl() {
    if (ciStatus == "DONE" && coStatus == "PENDING") {
      button_stat = true;
      return ListTile(
        title: const Text('CHECK OUT'),
        leading: Radio<SingingCharacter>(
          value: SingingCharacter.CHECKOUT,
          groupValue: _character,
          onChanged: (SingingCharacter? value) {
            setState(() {
              _character = value;
            });
          },
        ),
      );
    } else if (ciStatus == "DONE" && coStatus == "DONE") {
      setState(() {
        button_stat = false;
      });
      return ListTile(
        leading: Icon(
          Icons.check,
          color: Colors.green,
        ),
        title: Text(
          'CHECK OUT DONE FOR TODAY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      setState(() {
        button_stat = true;
      });
      return ListTile(
        leading: Icon(
          Icons.clear,
          color: Colors.red,
          size: 30,
        ),
        title: Text(
          'CHECK IN NOT DONE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
