import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/screens/testDetails.dart';

class TestCard extends StatelessWidget {
  final String text;
  final bool iconBool;
  TestCard({this.text, this.iconBool});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestDetails(test: text))
            );
          },
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          color: MyColors.offWhite,
          padding: EdgeInsets.all(6.0),
          child: ListTile(
            trailing: iconBool
                ? Icon(Icons.check, color: MyColors.green)
                : Icon(Icons.clear, color: Colors.red),
            title: Text(
              text,
              style: Theme.of(context).textTheme.headline6.copyWith(color: MyColors.darkPrimary, fontWeight: FontWeight.bold)
            ),
          )
        ),
      ),
    );
  }
}
