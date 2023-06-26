import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'ML/Recognition.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final _db = FirebaseFirestore.instance;
  // Future<void> updateUserAndRecord(String email) async {
  //   UserRepository userRepository = UserRepository();
  //
  //   // Update record
  //   bool isUpdateSuccessful = await userRepository.updateRecord(email);
  //
  //   if (isUpdateSuccessful) {
  //     // Record update successful
  //     print('Record updated successfully');
  //   } else {
  //     // Record update failed
  //     print('Failed to update the record');
  //   }
  // }
  //
  // Future<bool> updateRecord(String email) async {
  //   print("ENTER UPDATION");
  //   final baseUrl =
  //       'https://script.google.com/macros/s/AKfycby_NW6V0Ez1cXzBOYp62mygnwMfw-toeb1Y4tUu2FlKixv2wUbrlcD_pnxg4XHonmW1/exec';
  //   final putUrl = Uri.parse(baseUrl + '?email=$email');
  //
  //   final response =
  //       await http.post(putUrl, headers: {'X-HTTP-Method-Override': 'PUT'});
  //   print(response.body);
  //
  //   if (response.statusCode == 200) {
  //     print("SUCCESS");
  //     return true; // Update successful
  //   } else {
  //     print("UNSUCESSFUL");
  //     return false; // Update failed
  //   }
  // }

  createUser(UserFace user) async {
    await _db
        .collection("users")
        .add(user.toJson(user.name, user.left, user.top, user.right,
            user.bottom, user.embeddings, user.distance))
        .whenComplete(() => print("Done"))
        .catchError((error, stackTrace) {
      print(error.toString());
    });
  }

  getUserByName(String name) async {
    var querySnapshot = await _db
        .collection("users")
        .where("name", isEqualTo: name)
        .get()
        .catchError((error) {
      print(error.toString());
    });
    // var retrievedName = "Unknowm";
    // var retrievedLeft = 0.0;
    // var retrievedTop = 0.0;
    // var retrievedRight = 0.0;
    // var retrievedBottom = 0.0;
    // var retrievedEmbeddings ;
    // var retrievedDistance = 10;
    if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
      var documentSnapshot = querySnapshot.docs.first;
      var userData = documentSnapshot.data();

      // Access the fields of the retrieved document
      var retrievedName = userData["name"];
      var retrievedLeft = userData["left"];
      var retrievedTop = userData["top"];
      var retrievedRight = userData["right"];
      var retrievedBottom = userData["bottom"];
      var retrievedEmbeddings = userData["embeddings"];
      var retrievedDistance = userData["distance"];

      Rect loc;
      loc = Rect.fromLTRB(
          retrievedLeft, retrievedTop, retrievedRight, retrievedBottom);

      // Do something with the retrieved data
      print("Name: $retrievedName");
      print("Left: $retrievedLeft");
      print("Top: $retrievedTop");
      print("Right: $retrievedRight");
      print("Bottom: $retrievedBottom");
      print("Embeddings: $retrievedEmbeddings");
      print("Distance: $retrievedDistance");
    } else {}
  }

//   Future<UserFace> getUserFace(String name) async {
//     print(name);
//     final snapshot =
//         await _db.collection("users").where("name", isEqualTo: name).get();
//     final userData = snapshot.docs.map((e) => UserFace.fromSnapshot(e)).single;
//     return userData;
//   }
// }

//   Future<String?> getUserFace(String name) async {
//     try {
//       CollectionReference users =
//           FirebaseFirestore.instance.collection('users');
//       final snapshot = await users.doc(name).get();
//       final data = snapshot.data() as Map<String, dynamic>;
//       print(data['name']);
//       return data['name'];
//     } catch (e) {
//       return 'Error fetching user';
//     }
//   }
// }
}
