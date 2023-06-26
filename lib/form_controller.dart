import 'dart:convert' as convert;
//import 'dart:html';
import 'package:autheticationscreen/Auth.dart';
import 'package:autheticationscreen/HomePage.dart';
import 'package:http/http.dart' as http;
import "form.dart";

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class FormController {
  // Google App Script Web URL.
  Uri URL = Uri.parse(
      "https://script.google.com/macros/s/AKfycbzf4tLujm2Wz2kAHjSrkRTtEHRbgd0BgEIpdZJpQyLuSkHjXpZSfMkS4Q13Ilf2bvCxYA/exec");
  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      await http.post(URL, body: feedbackForm.toJson()).then((response) async {
        print(response.body);
        if (response.statusCode == 302) {
          var url = Uri.parse(response.headers['location']!);
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Future<List<FeedbackForm>> getFeedbackList(String email) async {
  //   return await http.get(URL).then((response) {
  //     var jsonFeedback = convert.jsonDecode(response.body) as List;
  //     return jsonFeedback.map((json) => FeedbackForm.fromJson(json)).toList();
  //   });

  //}
}
