import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class VerificationCard extends StatelessWidget {
  final String text;
  final String route;
  final bool iconBool;
  VerificationCard({this.text, this.route, this.iconBool});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width,
      child: RaisedButton(
        elevation: 5,
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: MyColors.darkPrimary, width: 1)),
        color: MyColors.white,
        padding: EdgeInsets.all(18),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: MyColors.darkPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Expanded(
                    child: iconBool == true
                        ? Icon(Icons.check, color: MyColors.green)
                        : Icon(Icons.clear, color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
