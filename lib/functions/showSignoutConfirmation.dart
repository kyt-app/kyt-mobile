import 'package:flutter/material.dart';
import 'package:kyt/functions/signOutFirebaseUser.dart';
import 'package:kyt/global/myColors.dart';

showSignoutConfirmation(BuildContext context, auth) {
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
      signOutFirebaseUser(auth, context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Sign out confirmation",
        style: TextStyle(color: MyColors.darkPrimary)),
    content: Text("Are you sure you want to sign out?",
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
