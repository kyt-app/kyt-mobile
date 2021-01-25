import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/welcome.dart';
import 'screens/verification/1.dart';
import 'screens/verification/2.dart';
import 'screens/verification/3.dart';

void main() {
  runApp(Kyt());
}

class Kyt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYT',
      theme: ThemeData(fontFamily: "lexenddeca"),
      initialRoute: Welcome.id,
      routes: {
        Home.id: (context) => Home(),
        Login.id: (context) => Login(),
        Signup.id: (context) => Signup(),
        Welcome.id: (context) => Welcome(),
        Verification1.id: (context) => Verification1(),
        Verification2.id: (context) => Verification2(),
        Verification3.id: (context) => Verification3(),
      },
    );
  }
}
