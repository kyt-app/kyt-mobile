import 'package:flutter/material.dart';
import 'package:kyt/screens/login.dart';

Future<void> signOutFirebaseUser(auth, BuildContext context) async {
  await auth.signOut();
  Navigator.popUntil(context, ModalRoute.withName(Login.id));
  // TODO: Add a toast or something because snackbar won't work
}
