import 'package:autheticationscreen/authFunction.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Auth.dart';
import 'HomePage.dart';
import 'MarkPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'PunchPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'STA',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
        ),
        home: AuthUser(),
        routes: <String, WidgetBuilder>{
          '/b': (BuildContext context) => PunchPage()
        });
  }
}
