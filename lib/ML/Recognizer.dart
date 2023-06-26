import 'dart:math';
import 'dart:ui' as ui;
import 'package:autheticationscreen/RecognitionScreen.dart';
import 'package:image/image.dart' as img;
import 'package:autheticationscreen/HomeScreen.dart';
import 'package:autheticationscreen/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import '../HomePage.dart';
import 'Recognition.dart';
import '../main.dart';
import 'package:autheticationscreen/confirmation_screen.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late var _probabilityProcessor;

  static String Error = "No Error";

  @override
  String get modelName => 'mobile_face_net.tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.nearestneighbour))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Recognition recognize(img.Image image, Rect location) {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print('Time to load image: $pre ms');
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');
    //
    _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    print(_outputBuffer.getDoubleList());
    Pair pair = findNearest(_outputBuffer.getDoubleList());
    // Pair pair = await findFace(_outputBuffer.getDoubleList());

    return Recognition(
        name: pair.name,
        location: location,
        embeddings: _outputBuffer.getDoubleList(),
        distance: pair.distance);
  }

  Future<Recognition> recognize2(img.Image image, Rect location) async {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print('Time to load image: $pre ms');
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');
    //
    _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    print(_outputBuffer.getDoubleList());
    // Pair pair = findNearest(_outputBuffer.getDoubleList());
    Pair pair = await findFace(_outputBuffer.getDoubleList());

    return Recognition(
        name: pair.name,
        location: location,
        embeddings: _outputBuffer.getDoubleList(),
        distance: pair.distance);
  }

  //TODO  looks for the nearest embeeding in the dataset
  // and retrurns the pair <id, distance>
  findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", -5);
    print(HomeScreen.registered.entries);
    for (MapEntry<String, Recognition> item in HomeScreen.registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
    }
    return pair;
  }

  findFace(List<double> emb) async {
    RecognitionScreen.autheticatiion = false;
    Pair pair = Pair("Unknown", -5);
    bool facesMatch = false;
    if (pair != null) {
      var firestoreService = UserFirestoreService();
      var recognition2 =
          await firestoreService.getUserByName(SecondPage.exporter.name);

      if (recognition2 != null) {
        facesMatch =
            matchFaces(_outputBuffer.getDoubleList(), recognition2, 1, pair);
        if (facesMatch) {
          print("true");
          RecognitionScreen.autheticatiion = true;
          return pair;
        } else {
          print("false");
          Error = "FACES DON'T MATCH";
          RecognitionScreen.autheticatiion = false;
          return Pair("Unknown", -5);
        }
      } else {
        Error = "FACE YET TO BE REGISTERED";
        pair = Pair("Unknown", -5);
        return pair;
      }
    } else {
      Error = "UNABLE TO FIND A FACE";
      RecognitionScreen.autheticatiion = false;
      pair = Pair("Unknown", -5);
      return pair;
    }

    // List<double> knownEmb = recognition2!.embeddings;
    // double distance = 0;
    // for (int i = 0; i < emb.length; i++) {
    //   double diff = emb[i] - knownEmb[i];
    //   distance += diff * diff;
    // }
    // distance = sqrt(distance);
    // if (pair.distance == -5 || distance < pair.distance) {
    //   pair.distance = recognition2.distance;
    //   pair.name = recognition2.name;
    // }
    // return pair;
  }

  bool matchFaces(List<double> emb, Recognition recognition2,
      double distanceThreshold, Pair pair) {
    List<double> embeddings1 = emb;
    List<double> embeddings2 = recognition2.embeddings;

    double distance = 0;
    for (int i = 0; i < embeddings1.length; i++) {
      double diff = embeddings1[i] - embeddings2[i];
      distance += diff * diff;
    }
    distance = sqrt(distance);
    if (pair.distance == -5 || distance < pair.distance) {
      pair.distance = distance;
      pair.name = SecondPage.exporter.name;
    }

    return distance <= distanceThreshold;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  double distance;
  Pair(this.name, this.distance);
}
