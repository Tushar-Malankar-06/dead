import 'dart:ffi';

import 'package:autheticationscreen/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autheticationscreen/Auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'ML/Recognition.dart';
import 'form.dart';
import 'form_controller.dart';

signup(String email, String password, BuildContext context,
    bool savepassword) async {
  print("insigh up");
  print(email);
  print(password);
  //AuthUser.sessionemail = email;
  // Navigator.push(
  //context, MaterialPageRoute(builder: (context) => EmailValidator()));
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    print(email);
    print(password);
    if (savepassword == true) {
      print("saving of credentials done");
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("email", email);
      pref.setString("password", password);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      const snackBar = SnackBar(
        content: Text('Password Weak'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (e.code == 'email-already-in-use') {
      const snackBar = SnackBar(
        content: Text('User already exist'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } catch (e) {
    print(e);
  }
}

signin(String emailAddress, String password, BuildContext context,
    bool savepassword) async {
  AuthUser.sessionemail = "not found";
  AuthUser.uid = "no found";
  try {
    print("hello");
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);

    AuthUser.sessionemail = emailAddress;
    AuthUser.uid = credential.user!.uid;
    if (savepassword == true) {
      print("saving of credentials done");
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("email", emailAddress);
      pref.setString("password", password);
    }
    getProfile(emailAddress, context);
    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => SecondPage(
    //               title: "Home",
    //               email: emailAddress,
    //               uid: AuthUser.uid,
    //             )));
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      const snackBar = SnackBar(
        content: Text('User Does not Exist'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (e.code == 'wrong-password') {
      const snackBar = SnackBar(
        content: Text('Incorrect Password'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

Future<AuthUser> signout(context) async {
  print("AuthUser Returned and prefernece cleaned");
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove("email");
  pref.remove("password");
  pref.remove("QS");
  pref.remove("CI/C0");
  pref.remove("Date");
  pref.remove("Time");
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const AuthUser()));
  return AuthUser();
}

void getProfile(String email, BuildContext context) async {
  // Success Status Message
  var STATUS_SUCCESS = "SUCCESS";
  print(email);
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbzf4tLujm2Wz2kAHjSrkRTtEHRbgd0BgEIpdZJpQyLuSkHjXpZSfMkS4Q13Ilf2bvCxYA/exec';
  final url = Uri.parse(baseUrl + '?email=$email');

  final response = await http.get(url);
  print(response.body);
  if (response.statusCode == 200) {
    List jsonFeedback = convert.jsonDecode(response.body) as List;
    if (jsonFeedback.isEmpty) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SecondPage(
                    title: "Home",
                    email: email,
                    uid: AuthUser.uid,
                    name: "New User",
                    isAdmin: false,
                    face_reg: false,
                    isSTA: false,
                  )));
    } else {
      var json = FeedbackForm.fromJson(jsonFeedback.first);
      print("false from here");
      var firestoreService = UserFirestoreService();
      var face_reg;
      var recognition2 = await firestoreService.getUserByName(json.name);
      if (recognition2 == null) {
        face_reg = false;
      } else {
        face_reg = true;
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SecondPage(
                    title: "Home",
                    email: email,
                    uid: AuthUser.uid,
                    name: json.name,
                    isAdmin: (json.admin.toLowerCase() == 'true'),
                    face_reg: face_reg,
                    isSTA: (json.sta.toLowerCase() == 'TRUE'.toLowerCase()),
                  )));
    }
  } else {
    throw Exception('Failed to retrieve feedback list');
  }
}
