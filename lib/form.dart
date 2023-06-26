import 'package:autheticationscreen/HomePage.dart';

/// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String uid;
  String name;
  String email;
  String mobileNo;
  String admin = "false";
  String sta = "yes";
  String face = "FALSE";

  FeedbackForm(
      this.uid, this.name, this.email, this.mobileNo, this.admin, this.sta);

  factory FeedbackForm.fromJson(dynamic json) {
    json['face'] == "FALSE"
        ? SecondPage.face_status = false
        : SecondPage.face_status = true;
    print(json['face']);
    return FeedbackForm("${json['uid']}", "${json['name']}", "${json['email']}",
        "${json['mobileNo']}", "${json['admin']}", "${json['sta']}");
  }

  // Method to make GET parameters.
  Map toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'mobileNo': mobileNo,
        'admin': admin,
        'sta': sta
      };
}
