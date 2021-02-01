import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class VerifyCard extends StatelessWidget {
  final String text;
  final String route;
  VerifyCard({this.text, this.route});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width,
      child: RaisedButton(
        elevation: 5,
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color: MyColors.offWhite,
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
            ],
          ),
        ),
      ),
    );
  }
}
