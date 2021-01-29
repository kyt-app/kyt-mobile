import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/welcome.dart';
import 'screens/upload.dart';
import 'screens/verification/1.dart';
import 'screens/verification/2.dart';
import 'screens/verification/3.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Kyt());
}

class Kyt extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // return error widget
          return Text('');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'KYT',
            theme: ThemeData(fontFamily: "lexenddeca"),
            initialRoute: Welcome.id,
            routes: {
              Login.id: (context) => Login(),
              Register.id: (context) => Register(),
              Welcome.id: (context) => Welcome(),
              Upload.id: (context) => Upload(),
              Verification1.id: (context) => Verification1(),
              Verification2.id: (context) => Verification2(),
              Verification3.id: (context) => Verification3(),
            },
          );
        }

        // show loader while initializing
        return CircularProgressIndicator();
      }
    );
  }
}
