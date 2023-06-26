import 'dart:io';
import 'package:autheticationscreen/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ML/Recognition.dart';
import 'confirmation_screen.dart';
import 'dataExport.dart';
import 'form_controller.dart';
import 'get_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'ML/Recognizer.dart';
import 'main.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({Key? key}) : super(key: key);
  static bool autheticatiion = false;
  static bool isLoading = false;
  @override
  State<RecognitionScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RecognitionScreen> {
  //TODO CIRCULAR PROGRESS INDICATOR

  String authetication_indicator = "PENDING";
  //TODO declare variables
  late ImagePicker imagePicker;
  File? _image;
  var image;
  List<Recognition> recognitions = [];
  List<Face> faces = [];
  //TODO declare detector
  dynamic faceDetector;

  //TODO declare face recognizer
  late Recognizer _recognizer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();

    //TODO initialize detector
    final options = FaceDetectorOptions(
        enableClassification: false,
        enableContours: false,
        enableLandmarks: false);

    //TODO initalize face detector
    faceDetector = FaceDetector(options: options);

    //TODO initalize face recognizer
    _recognizer = Recognizer();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  //TODO DISABLE A BUTTON
  void button_control() {
    setState(() {
      bool button_enabled = true;
    });
  }

  //TODO face detection code here
  TextEditingController textEditingController = TextEditingController();
  doFaceDetection() async {
    faces.clear();

    //TODO remove rotation of camera images
    _image = await removeRotation(_image!);

    //TODO passing input to face detector and getting detected faces
    final inputImage = InputImage.fromFile(_image!);
    //TODO change it to one face only
    faces = await faceDetector.processImage(inputImage);

    if (faces.length == 0) {
      setState(() {
        authetication_indicator = "UNSUCESSFUL";
      });
    }

    //TODO call the method to perform face recognition on detected faces
    performFaceRecognition();
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage =
        img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  //TODO perform Face Recognition

  performFaceRecognition() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    print("${image.width}   ${image.height}");

    recognitions.clear();
    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      num left = faceRect.left < 0 ? 0 : faceRect.left;
      num top = faceRect.top < 0 ? 0 : faceRect.top;
      num right =
          faceRect.right > image.width ? image.width - 1 : faceRect.right;
      num bottom =
          faceRect.bottom > image.height ? image.height - 1 : faceRect.bottom;
      num width = right - left;
      num height = bottom - top;

      // TODO crop face
      File cropedFace = await FlutterNativeImage.cropImage(_image!.path,
          left.toInt(), top.toInt(), width.toInt(), height.toInt());
      final bytes = await File(cropedFace.path).readAsBytes();
      final img.Image? faceImg = img.decodeImage(bytes);
      Recognition recognition =
          await _recognizer.recognize2(faceImg!, face.boundingBox);

      TextStyle boldTextStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      );

      if (RecognitionScreen.autheticatiion == true) {
        setState(() {
          authetication_indicator = "SUCCESSFUL";
          SecondPage.exporter.faceauth = "TRUE";
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication Successful',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Name: ${SecondPage.exporter.name}',
                          style: boldTextStyle),
                      Icon(Icons.check_circle, color: Colors.green, size: 40),
                      Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            {
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => SecondPage(
                                            title: "Home",
                                            uid: SecondPage.exporter.uid,
                                            email: SecondPage.exporter.email,
                                            name: SecondPage.exporter.name,
                                            isAdmin: SecondPage
                                                .enableAdminPriviliges,
                                            face_reg: SecondPage.face_status,
                                            isSTA: true,
                                          )));
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
                              submitForm(SecondPage.exporter,
                                  (String response) {
                                print(response);
                                print("Response: $response");
                                if (response == FormController.STATUS_SUCCESS) {
                                  print("Hello");
                                  // Feedback is saved succesfully in Google Sheets.
                                  final snackBar = SnackBar(
                                    content: Text('Attendance Done'),
                                    duration: Duration(seconds: 2),
                                  );

                                  Storetime();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  // Error Occurred while saving data in Google Sheets.
                                  final snackBar = SnackBar(
                                    content: Text('ERROR OCCURED'),
                                    duration: Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.blue.withOpacity(0.1),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else if (RecognitionScreen.autheticatiion == false) {
        setState(() {
          authetication_indicator = "UNSUCCESSFUL";
          SecondPage.exporter.faceauth = "FALSE";
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Authentication Failed',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Name: ${SecondPage.exporter.name}',
                          style: boldTextStyle),
                      Icon(Icons.clear, color: Colors.red, size: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog box
                            },
                            child: Text(
                              'Try Again',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Are you sure?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // TODO: Handle submit without authentication button action

                                            {
                                              Navigator.pop(context);
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SecondPage(
                                                                title: "Home",
                                                                uid: SecondPage
                                                                    .exporter
                                                                    .uid,
                                                                email: SecondPage
                                                                    .exporter
                                                                    .email,
                                                                name: SecondPage
                                                                    .exporter
                                                                    .name,
                                                                isAdmin: SecondPage
                                                                    .enableAdminPriviliges,
                                                                face_reg: SecondPage
                                                                    .face_status,
                                                                isSTA: true,
                                                              )));
                                              print(SecondPage.exporter.name);
                                              print(SecondPage.exporter.email);
                                              print(
                                                  SecondPage.exporter.movement);
                                              print(
                                                  SecondPage.exporter.distance);
                                              print(
                                                  SecondPage.exporter.latitude);
                                              print(SecondPage
                                                  .exporter.longitute);
                                              print(
                                                  SecondPage.exporter.faceauth);
                                              print(SecondPage.exporter.date);
                                              print(SecondPage.exporter.uid);
                                              print(SecondPage.exporter.time);
                                              submitForm(SecondPage.exporter,
                                                  (String response) async {
                                                print(response);
                                                print("Response: $response");
                                                if (response ==
                                                    FormController
                                                        .STATUS_SUCCESS) {
                                                  print("Hello");
                                                  // Feedback is saved succesfully in Google Sheets.

                                                  final snackBar = SnackBar(
                                                    content:
                                                        Text('Attendance Done'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  );
                                                  // Navigator.of(context).pushReplacement(
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) => SecondPage(
                                                  //             title: "Home",
                                                  //             uid: SecondPage
                                                  //                 .exporter.uid,
                                                  //             email: SecondPage
                                                  //                 .exporter
                                                  //                 .email,
                                                  //             name: SecondPage
                                                  //                 .exporter
                                                  //                 .name,
                                                  //             isAdmin: SecondPage
                                                  //                 .enableAdminPriviliges,
                                                  //             face_reg: SecondPage
                                                  //                 .face_status,
                                                  //             isSTA: true)));

                                                  Storetime();

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else {
                                                  // Error Occurred while saving data in Google Sheets.
                                                  final snackBar = SnackBar(
                                                    content:
                                                        Text('ERROR OCCURED'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                }
                                              });
                                            }
                                            Navigator.pop(
                                                context); // Close the confirmation dialog
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Close the confirmation dialog
                                          },
                                          child: Text(
                                            'No',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Submit',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      if (recognition.distance > 1) {
        recognition.name = "Unknown";
      } else {
        recognition.name = SecondPage.exporter.name;
      }
      recognitions.add(recognition);
    }
    drawRectangleAroundFaces();
  }

  //TODO draw rectangles
  drawRectangleAroundFaces() async {
    setState(() {
      image;
      faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(SecondPage.exporter.movement),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    image != null
                        ? Container(
                            margin: const EdgeInsets.only(
                                top: 60, left: 30, right: 30, bottom: 0),
                            child: FittedBox(
                              child: SizedBox(
                                width: image.width.toDouble(),
                                height: image.width.toDouble(),
                                child: CustomPaint(
                                  painter: FacePainter(
                                      facesList: recognitions,
                                      imageFile: image),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Image.asset(
                              "images/logo.png",
                              width: screenWidth - 100,
                              height: screenWidth - 100,
                            ),
                          ),

                    SizedBox(
                      height: 100.0,
                    ),

                    //section which displays buttons for choosing and capturing images
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Card(
                          //   shape: const RoundedRectangleBorder(
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(200))),
                          //   child: InkWell(
                          //     onTap: () {
                          //       _imgFromGallery();
                          //     },
                          //     child: SizedBox(
                          //       width: screenWidth / 3 - 50,
                          //       height: screenWidth / 3 - 50,
                          //       child: Icon(Icons.image,
                          //           color: Colors.blue, size: screenWidth / 9),
                          //     ),
                          //   ),
                          // ),
                          Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(200))),
                            child: InkWell(
                              onTap: () async {
                                await _imgFromCamera();
                              },
                              child: SizedBox(
                                width: screenWidth / 3 - 50,
                                height: screenWidth / 3 - 50,
                                child: Icon(Icons.camera,
                                    color: Colors.blue, size: screenWidth / 9),
                              ),
                            ),
                          ),
                          authetication_indicator != "PENDING"
                              ? Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(200))),
                                  child: InkWell(
                                    onTap: () async {
                                      SecondPage.exporter.faceauth =
                                          RecognitionScreen.autheticatiion
                                              .toString();
                                      bool endTime = await checkTime();
                                      if (endTime == true) {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) => AuthPage(
                                                    authenticationSuccess:
                                                        RecognitionScreen
                                                            .autheticatiion)));
                                      } else {
                                        Navigator.pop(context);
                                        final snackdemo = SnackBar(
                                          content: Text("Session Expired"),
                                          elevation: 10,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(5),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackdemo);
                                      }
                                    },
                                    child: SizedBox(
                                      width: screenWidth / 3 - 50,
                                      height: screenWidth / 3 - 50,
                                      child: Icon(Icons.check,
                                          color: Colors.blue,
                                          size: screenWidth / 9),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        authetication_indicator == "SUCCESSFUL"
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: authetication_indicator == "SUCCESSFUL"
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        "FACE AUTHENTICATION STATUS:   " +
                            authetication_indicator,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: authetication_indicator == "SUCCESSFUL"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkTime() async {
    String time1 = SecondPage.exporter.time;
    String time2 = await getTime().setup(false);
    String date = getTime().convertToDateTimeFormat(SecondPage.exporter.date);
    DateTime dateTime1 = DateTime.parse("${date} $time1:00");
    DateTime dateTime2 = DateTime.parse("${date} $time2:00");

    Duration difference = dateTime2.difference(dateTime1);
    int differenceInMinutes = difference.inMinutes;

    print('The difference in minutes is: $differenceInMinutes');
    if (differenceInMinutes <= 1) {
      return true;
    } else {
      return false;
    }
  }

  Storetime() async {
    try {
      print("entered");
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("QS", "enabled");
      pref.setString("CI/C0", SecondPage.exporter.movement);
      pref.setString("Date", SecondPage.exporter.date);
      pref.setString("Time", SecondPage.exporter.time);
      print("done");
    } catch (e) {
      print("Exception while storing preferences: $e");
      // Handle the exception or display an error message as needed
    }
  }
}

class FacePainter extends CustomPainter {
  List<Recognition> facesList;
  dynamic imageFile;

  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      final imageSize =
          Size(imageFile.width.toDouble(), imageFile.height.toDouble());
      final destinationRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final sourceRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
      canvas.drawImageRect(imageFile, sourceRect, destinationRect, Paint());
    }

    if (facesList.isNotEmpty) {
      final scaleX = size.width / imageFile.width;
      final scaleY = size.height / imageFile.height;

      Paint p = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      for (Recognition rectangle in facesList) {
        Rect scaledRect = Rect.fromLTRB(
          rectangle.location.left * scaleX,
          rectangle.location.top * scaleY,
          rectangle.location.right * scaleX,
          rectangle.location.bottom * scaleY,
        );

        canvas.drawRect(scaledRect, p);

        TextSpan span = TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 90),
          text: "${rectangle.name}  ${rectangle.distance.toStringAsFixed(2)}",
        );

        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        tp.layout();
        tp.paint(canvas, Offset(scaledRect.left, scaledRect.top));
      }
    }

    Paint p2 = Paint();
    p2.color = Colors.green;
    p2.style = PaintingStyle.stroke;
    p2.strokeWidth = 3;

    Paint p3 = Paint();
    p3.color = Colors.yellow;
    p3.style = PaintingStyle.stroke;
    p3.strokeWidth = 1;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
