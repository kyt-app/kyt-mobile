import 'package:flutter/material.dart';
import 'package:kyt/screens/login.dart';

Future<void> signOutFirebaseUser(auth, BuildContext context) async {
  await auth.signOut();
  Navigator.of(context)
      .pushNamedAndRemoveUntil(Login.id, ModalRoute.withName(Login.id));
}
