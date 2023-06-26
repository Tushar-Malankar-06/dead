import 'package:autheticationscreen/Auth.dart';
import 'package:autheticationscreen/QR_CODE.dart';
import 'package:autheticationscreen/employeeApp.dart';
import 'package:autheticationscreen/get_time.dart';
import 'package:autheticationscreen/quick_submit.dart';
import 'package:autheticationscreen/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authFunction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dataExport.dart';

import 'form.dart';
import 'form_controller.dart';

class SecondPage extends StatelessWidget {
  SecondPage(
      {Key? key,
      required this.title,
      required this.uid,
      required this.email,
      required this.name,
      required this.isAdmin,
      required this.face_reg,
      required this.isSTA})
      : super(key: key);
  final String title;
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;
  final bool face_reg;
  final bool isSTA;
  bool isProfile = true;
  static bool face_status = false;
  static late Exporter exporter = Exporter(
      uid: "",
      name: "",
      email: "",
      movement: "",
      longitute: "",
      latitude: "",
      distance: "",
      date: "",
      time: "",
      sta: "",
      faceauth: "false");
  static bool enableAdminPriviliges = false;

  Future<bool> getFeedbackList(String email, BuildContext context) async {
    // Success Status Message
    var STATUS_SUCCESS = "SUCCESS";
    print(email);
    final baseUrl =
        'https://script.google.com/macros/s/AKfycbzf4tLujm2Wz2kAHjSrkRTtEHRbgd0BgEIpdZJpQyLuSkHjXpZSfMkS4Q13Ilf2bvCxYA/exec';
    final url = Uri.parse(baseUrl + '?email=$email');

    print(url);

    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      List jsonFeedback = convert.jsonDecode(response.body) as List;
      if (jsonFeedback.isEmpty) {
        final snackdemo = SnackBar(
          content: Text(email),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackdemo);

        return false;
      } else {
        var json = FeedbackForm.fromJson(jsonFeedback.first);
        print("false from here");
        if (json.sta.toLowerCase() == "false") {
          final snackdemo = SnackBar(
            content: Text("Yet to Accepted"),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackdemo);

          return true;
        } else {
          print("Accepted");
          SecondPage.exporter.email = email;
          SecondPage.exporter.sta = "Yes";
          SecondPage.exporter.uid = uid;
          SecondPage.exporter.name = json.name;
          return true;
        }
      }
    } else {
      throw Exception('Failed to retrieve feedback list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(title),
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 25, 63, 92),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () async {
                    signout(context);
                  },
                  icon: Icon(Icons.logout)),
            ]),
        body: SingleChildScrollView(
          child: Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: ProfileCard(data: name, title: email),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              face_reg == true
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.navigate_next_outlined),
                                        title: Text('ATTENDANCE - 1 MIN'),
                                        onTap: () async {
                                          SecondPage.enableAdminPriviliges =
                                              isAdmin;
                                          print(email.length);
                                          bool a = await getFeedbackList(
                                              email, context);
                                          if (a == false) {
                                            final snackdemo = SnackBar(
                                              content: Text(
                                                  "Please Apply as STA Employee"),
                                              elevation: 10,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.all(5),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackdemo);
                                          } else {
                                            Navigator.pushNamed(context, '/b');
                                          }
                                          ;
                                        },
                                      ),
                                    )
                                  : Container(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.navigate_next_outlined),
                                  title: Text('APPLY FOR STA'),
                                  onTap: () async {
                                    print(email.length);
                                    bool a =
                                        await getFeedbackList(email, context);
                                    if (a == true) {
                                      final snackdemo = SnackBar(
                                        content: Text("Already Applied"),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackdemo);
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EmployeeReg(
                                                      title: "Apply")));
                                    }
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.navigate_next_outlined),
                                  title: Text('QUICK ATTENDANCE'),
                                  onTap: () async {
                                    bool a =
                                        await getFeedbackList(email, context);
                                    if (a == false) {
                                      final snackdemo = SnackBar(
                                        content: Text(
                                            "Please Apply as STA Employee"),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackdemo);
                                    } else {
                                      await retrieveTime(context);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 16.0),
                              (face_reg == false && isSTA == true)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              Color.fromARGB(255, 25, 63, 92),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: ListTile(
                                        leading: Icon(Icons.face_2_outlined),
                                        title: Text(
                                          "Face Registration",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 25, 63, 92),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        onTap: () {
                                          SecondPage.exporter.name = name;
                                          SecondPage.exporter.email = email;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const QRVIEW()));
                                        },
                                      ),
                                    )
                                  : Container()
                            ]),
                      ))
                ]),
          ),
        ));
  }

  Future<void> retrieveTime(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String qs = pref.getString("QS") ?? "";
    String movement = pref.getString("CI/C0") ?? "";
    String date = pref.getString("Date") ?? "";
    String time = pref.getString("Time") ?? "";

    getTime timeGetter = getTime();
    String currentDate = await timeGetter.setup(true);
    String currentTime = await timeGetter.setup(false);

    if (qs != "enabled") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Do normal attendance once"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      if (date == currentDate) {
        if (movement == "CHECKIN") {
          SecondPage.exporter.date = currentDate;
          SecondPage.exporter.time = currentTime;
          SecondPage.exporter.movement = "CHECKOUT";
          QuickSubmit().QuickLocation(context);
        } else if (movement == "CHECKOUT") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Alert"),
                content: Text("CHECKIN AND CHECKOUT DONE"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        SecondPage.exporter.date = currentDate;
        SecondPage.exporter.time = currentTime;
        SecondPage.exporter.movement = "CHECKIN";
        QuickSubmit().QuickLocation(context);
      }
    }

    // Use the retrieved and updated values as desired
    print("QS: $qs");
    print("CI/C0: $movement");
    print("Date: ${SecondPage.exporter.date}");
    print("Time: $time");
  }
}

class ProfileCard extends StatelessWidget {
  final String title;
  final String data;

  ProfileCard({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.amberAccent,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              radius: 50.0,
              child: Image.asset("images/logo.png"),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 63, 92),
                    ),
                  ),
                  Text(
                    data,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Email:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 63, 92),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
