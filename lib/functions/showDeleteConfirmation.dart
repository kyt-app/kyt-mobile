import 'package:flutter/material.dart';
import 'package:kyt/functions/deleteTest.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/screens/navigation.dart';

showDeleteConfirmation(BuildContext context, details, user) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text(
      "Cancel",
      style: TextStyle(color: MyColors.green),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text(
      "Confirm",
      style: TextStyle(color: Colors.redAccent),
    ),
    onPressed: () {
      Future<String> res = deleteTest(details['testName'], user.uid);
      print(res);
      Navigator.pushNamed(context, Navigation.id);
      //TODO: Persistent interactive snackbar saying "test name" deleted
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete confirmation",
        style: TextStyle(color: MyColors.darkPrimary)),
    content: Text("Are you sure you want to delete your test details?",
        style: TextStyle(color: MyColors.lightPrimary)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
