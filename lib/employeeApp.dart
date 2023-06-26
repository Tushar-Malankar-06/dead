import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_controller.dart';
import 'Auth.dart';

import 'form.dart';

class EmployeeReg extends StatefulWidget {
  const EmployeeReg({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _EmployeeRegState createState() => _EmployeeRegState();
}

class _EmployeeRegState extends State<EmployeeReg> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      _showSnackbar("Submitting Feedback");
      Navigator.pop(context);
      Random random = Random();

      // If the form is valid, proceed.
      FeedbackForm feedbackForm = FeedbackForm(
          AuthUser.uid,
          nameController.text,
          AuthUser.sessionemail,
          mobileNoController.text,
          "false",
          "false");

      FormController formController = FormController();

      _showSnackbar("Submitting Feedback");
      Navigator.pop(context);

      // Submit 'feedbackForm' and save it in Google Sheets.
      formController.submitForm(feedbackForm, (String response) {
        print(response);
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          print("Hello");
          // Feedback is saved succesfully in Google Sheets.
          _showSnackbar("Feedback Submitted");
          Navigator.pop(context);
        } else {
          // Error Occurred while saving data in Google Sheets.
          _showSnackbar("Error Occurred!");
        }
      });
    }
  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackdemo = SnackBar(
      content: Text(message),
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackdemo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Valid Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: mobileNoController,
                        validator: (value) {
                          if (value?.trim().length != 10) {
                            return 'Enter 10 Digit Mobile Number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                        ),
                      ),
                    ],
                  ),
                )),
            ElevatedButton(onPressed: _submitForm, child: Text("Apply")),
          ],
        ),
      ),
    );
  }
}
