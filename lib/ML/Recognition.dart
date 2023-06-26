import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class Recognition {
  final String? id;
  String name;
  Rect location;
  List<double> embeddings;
  double distance;

  /// Constructs a Category.
  Recognition(
      {this.id,
      required this.name,
      required this.location,
      required this.embeddings,
      required this.distance});

  toJson(String name, Rect location, List<double> embeddings, double distance) {
    return {
      'name': name,
      'left': location.left,
      'top': location.top,
      'right': location.right,
      'bottom': location.bottom,
      'embeddings': embeddings,
      'distance': distance,
    };
  }
}

class UserFirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Recognition?> getUserByName(String name) async {
    var querySnapshot = await _db
        .collection("users")
        .where("name", isEqualTo: name)
        .get()
        .catchError((error) {
      print(error.toString());
    });

    if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
      var documentSnapshot = querySnapshot.docs.first;
      var userData = documentSnapshot.data();

      // Access the fields of the retrieved document
      var retrievedId = documentSnapshot.id;
      var retrievedName = userData["name"];
      var retrievedLeft = userData["left"];
      var retrievedTop = userData["top"];
      var retrievedRight = userData["right"];
      var retrievedBottom = userData["bottom"];
      var retrievedEmbeddings = userData["embeddings"];
      var retrievedDistance = userData["distance"];

      // Create a Recognition object with the retrieved data
      var recognition = Recognition(
        id: retrievedId,
        name: retrievedName,
        location: Rect.fromLTRB(
            retrievedLeft, retrievedTop, retrievedRight, retrievedBottom),
        embeddings: List<double>.from(retrievedEmbeddings),
        distance: retrievedDistance,
      );

      return recognition;
    } else {
      print("No document found with the provided name.");
      return null;
    }
  }
}

class UserFace {
  final String? id;
  String name;
  List<double> embeddings;
  double distance;
  double left;
  double top;
  double right;
  double bottom;

  UserFace({
    this.id,
    required this.name,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.embeddings,
    required this.distance,
  });

  factory UserFace.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return UserFace(
        id: document.id,
        name: data['name'],
        left: data['left'],
        right: data['right'],
        top: data['top'],
        bottom: data['bottom'],
        embeddings: data['embeddings'],
        distance: data['distance']);
  }

  toJson(String name, double left, double top, double right, double bottom,
      List<double> embeddings, double distance) {
    return {
      'name': name,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'embeddings': embeddings,
      'distance': distance,
    };
  }
}
