import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/welcome.dart';

void main() {
  runApp(Kyt());
}

class Kyt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: "lexenddeca"),
      initialRoute: Welcome.id,
      routes: {
        Home.id: (context) => Home(),
        Login.id: (context) => Login(),
        Signup.id: (context) => Signup(),
        Welcome.id: (context) => Welcome()
      },
    );
  }
}
