import 'package:flutter/material.dart';
import 'package:kyt/global/myStrings.dart';

class Welcome extends StatefulWidget {
  static String id = "welcome";
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[Text(MyStrings.appNameUppercase)],
      ),
    );
  }
}
