import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Text('Settings page actually 😃')
        )
      ),
    );
  }
}
