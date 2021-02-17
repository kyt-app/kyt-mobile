import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/userPictureAndName.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<String> getQRCodeLink(String authToken) async {
  final qrCodeEndpoint = Uri.parse(
      'https://kyt-api.azurewebsites.net/qrcode?authToken=$authToken');
  final response = await http.get(qrCodeEndpoint);

  if (response.statusCode == 200) {
    return json.decode(response.body)['url'];
  }

  return null;
}

class QRCode extends StatefulWidget {
  static String id = "qrCode";

  @override
  _QRCodeState createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getQRCodeLink(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: MyColors.offWhite,
                body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
              backgroundColor: MyColors.offWhite,
              body: Semantics(
                label: "QRCode",
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    UserPictureAndName(
                      user: user,
                    ),
                    MySpaces.vSmallGapInBetween,
                    QrImage(
                      data: snapshot.data,
                      version: QrVersions.auto,
                      size: 250.0,
                      foregroundColor: MyColors.darkPrimary,
                    ),
                    MySpaces.vMediumGapInBetween,
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 0),
                        child: Text(
                            'This is your pass for all the medical requirements for travel.\n\nSimply scan the code at a kiosk and you\'re good to go!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0)),
                      ),
                    )
                  ],
                ),
              ));
        });
  }
}
