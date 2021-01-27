import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/welcome.dart';
import 'screens/upload.dart';
import 'screens/verification/1.dart';
import 'screens/verification/2.dart';
import 'screens/verification/3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(Kyt(firstCamera: firstCamera));
}

class Kyt extends StatelessWidget {
  final CameraDescription firstCamera;

  const Kyt({Key key, this.firstCamera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYT',
      theme: ThemeData(fontFamily: "lexenddeca"),
      initialRoute: Welcome.id,
      routes: {
        Home.id: (context) => Home(),
        Login.id: (context) => Login(),
        Register.id: (context) => Register(),
        Welcome.id: (context) => Welcome(),
        Upload.id: (context) => Upload(camera: firstCamera),
        Verification1.id: (context) => Verification1(),
        Verification2.id: (context) => Verification2(),
        Verification3.id: (context) => Verification3(),
      },
    );
  }
}
