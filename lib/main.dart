import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kyt/screens/archivedRecords.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/welcome.dart';
import 'screens/navigation.dart';
import 'screens/testDetails.dart';

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
              Home.id: (context) => Home(),
              Login.id: (context) => Login(),
              Register.id: (context) => Register(),
              Welcome.id: (context) => Welcome(),
              Navigation.id: (context) => Navigation(),
              TestDetails.id: (context) => TestDetails(),
              ArchivedRecords.id: (context) => ArchivedRecords()
            },
          );
        }

        // show loader while initializing
        return CircularProgressIndicator();
      }
    );
  }
}
