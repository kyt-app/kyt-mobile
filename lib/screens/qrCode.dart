import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

Future<String> getQRCodeLink(String email) async {
  final qrCodeEndpoint = Uri.parse('https://kyt-api.azurewebsites.net/qrcode?email=$email');
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
      future: getQRCodeLink(user.email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: MyColors.offWhite,
            body: Center(child: CircularProgressIndicator())
          );
        }

        return Scaffold(
          backgroundColor: MyColors.offWhite,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: MyDimens.double_30),
                  color: MyColors.darkPrimary,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MyDimens.double_200),
                        child: Image.network(
                          '${user.photoURL}',
                          height: 100.0,
                          width: 100.0,
                        ),
                      ),
                      MySpaces.vGapInBetween,
                      Text(
                        '${user.displayName}',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: MyColors.white, fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  )
              ),
              QrImage(
                data: snapshot.data,
                version: QrVersions.auto,
                size: 250.0,
                foregroundColor: MyColors.darkPrimary,
              ),
              MySpaces.vGapInBetween,
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
                  child: Text(
                    'This is your pass for all the medical requirements for travel.\n\nSimply scan the code at a kiosk and you\'re good to go!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0)
                  ),
                ),
              )
            ],
          )
        );
      }
    );
  }
}
