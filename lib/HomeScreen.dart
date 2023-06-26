import 'package:autheticationscreen/HomePage.dart';
import 'package:autheticationscreen/QR_CODE.dart';

import 'ML/Recognizer.dart';
import 'RecognitionScreen.dart';
import 'RegistrationScreen.dart';
import 'user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ML/Recognition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static Map<String, Recognition> registered = Map();
  static late String authuser;

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    "images/logo.png",
                    width: screenWidth - 40,
                    height: screenWidth - 40,
                  )),
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     final snackBar = SnackBar(
                    //       content: Text('NOT AN ADMIN'),
                    //       duration: Duration(seconds: 2),
                    //     );
                    //     // SecondPage.enableAdminPriviliges
                    //     //     ?
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const QRVIEW()));
                    //     // : ScaffoldMessenger.of(context)
                    //     //     .showSnackBar(snackBar);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //       minimumSize: Size(screenWidth - 30, 50)),
                    //   child: const Text("Register"),
                    // ),
                    Container(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //showFaceReDialogue();
                        setState(() {
                          HomeScreen.authuser = SecondPage.exporter.name;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RecognitionScreen()));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenWidth - 30, 50)),
                      child: const Text("Recognize"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController _controller = TextEditingController();
  showFaceReDialogue() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration", textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter Name")),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  child: Text("Enter a name"),
                  onPressed: () {
                    setState(() {
                      HomeScreen.authuser = _controller.text;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecognitionScreen()));
                  })
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
