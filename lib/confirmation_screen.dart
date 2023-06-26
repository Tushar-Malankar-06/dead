import 'dart:math';

import 'package:autheticationscreen/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'package:flutter/material.dart';
import 'form.dart';
import 'form_controller.dart';
import 'dataExport.dart';
import 'get_time.dart';

class AuthPage extends StatelessWidget {
  final bool authenticationSuccess;
  static String endtime = "";

  AuthPage({required this.authenticationSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Authentication Page',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 25, 63, 92),
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  authenticationSuccess
                      ? 'Authentication Successful'
                      : 'Authentication Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                authenticationSuccess == false
                    ? ElevatedButton(
                        onPressed: () {
                          if (authenticationSuccess == false)
                            Navigator.of(context)
                                .pop(); // Go back to the previous page
                        },
                        child: Text('Try again'),
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      print(SecondPage.exporter.name);
                      print(SecondPage.exporter.email);
                      print(SecondPage.exporter.movement);
                      print(SecondPage.exporter.distance);
                      print(SecondPage.exporter.latitude);
                      print(SecondPage.exporter.longitute);
                      print(SecondPage.exporter.faceauth);
                      print(SecondPage.exporter.date);
                      print(SecondPage.exporter.uid);
                      print(SecondPage.exporter.time);
                      submitForm(SecondPage.exporter, (String response) {
                        print(response);
                        print("Response: $response");
                        if (response == FormController.STATUS_SUCCESS) {
                          print("Hello");
                          // Feedback is saved succesfully in Google Sheets.
                          final snackBar = SnackBar(
                            content: Text('Attendance Done'),
                            duration: Duration(seconds: 2),
                          );
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (context) => SecondPage(
                                        title: "Home",
                                        uid: SecondPage.exporter.uid,
                                        email: SecondPage.exporter.email,
                                        name: SecondPage.exporter.name,
                                        isAdmin:
                                            SecondPage.enableAdminPriviliges,
                                        face_reg: SecondPage.face_status,
                                        isSTA: true,
                                      )));

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          // Error Occurred while saving data in Google Sheets.
                          final snackBar = SnackBar(
                            content: Text('ERROR OCCURED'),
                            duration: Duration(seconds: 2),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      });
                    },
                    child: Text(authenticationSuccess == true
                        ? "Submit"
                        : "Submit w/o authetication")),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//   void submitForm(BuildContext context) {
//     // Validate returns true if the form is valid, or false
//     // otherwise.
//     Random random = Random();
//     String uid = (random.nextInt(900000) + 100000)
//         .toString(); // Generates a random number between 100000 and 999999
//
//     // If the form is valid, proceed.
//     FeedbackForm feedbackForm = FeedbackForm(uid, "Tushar Malankar",
//         'tmalankar@gmail.com', "7045002979", "false", "true");
//
//     FormController formController = FormController();
//
//     showSnackbar("Submitting Feedback", context);
//
//     // Submit 'feedbackForm' and save it in Google Sheets.
//     formController.submitForm(feedbackForm, (String response) {
//       print(response);
//       print("Response: $response");
//       if (response == FormController.STATUS_SUCCESS) {
//         print("Hello");
//         // Feedback is saved succesfully in Google Sheets.
//         showSnackbar("Feedback Submitted", context);
//       } else {
//         // Error Occurred while saving data in Google Sheets.
//         showSnackbar("Error Occurred!", context);
//       }
//     });
//   }
//
// // Method to show snackbar with 'message'.
//   showSnackbar(String message, BuildContext context) {
//     final snackdemo = SnackBar(
//       content: Text(message),
//       elevation: 10,
//       behavior: SnackBarBehavior.floating,
//       margin: EdgeInsets.all(5),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackdemo);
//   }
// }
