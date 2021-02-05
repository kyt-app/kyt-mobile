import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/screens/editProfile.dart';
import 'package:kyt/screens/login.dart';
import 'package:kyt/screens/reportABug.dart';
import 'package:kyt/widgets/settingsRow.dart';
import 'package:kyt/widgets/userPictureAndName.dart';

Future<String> getQRCodeLink(String email) async {
  final qrCodeEndpoint =
      Uri.parse('https://kyt-api.azurewebsites.net/qrcode?email=$email');
  final response = await http.get(qrCodeEndpoint);

  if (response.statusCode == 200) {
    return json.decode(response.body)['url'];
  }

  return null;
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    await auth.signOut();
    Navigator.pushNamed(context, Login.id);
    // TODO: Add a toast or something because snackbar won't work
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserPictureAndName(user: user),
          MySpaces.vMediumGapInBetween,
          Padding(
            padding: EdgeInsets.only(left: 38.0),
            child: Text(
              'Settings'.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: MyColors.darkPrimary,
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
            ),
          ),
          MySpaces.vGapInBetween,
          SettingsRow(
            icon: Icons.edit,
            label: 'Edit Profile',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditProfile()));
            },
          ),
          SettingsRow(
            icon: Icons.report,
            label: 'Report a bug',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ReportABug()));
            },
          ),
          MySpaces.vGapInBetween,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                child: ButtonTheme(
                  minWidth: 100.0,
                  child: RaisedButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0))),
                    padding: EdgeInsets.all(14.0),
                    color: MyColors.darkPrimary,
                    child: Text('Sign out',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: MyColors.white)),
                    onPressed: () {
                      var snackBar = SnackBar(content: Text('Signing out'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _signOut();
                    },
                  ),
                ),
                padding: EdgeInsets.only(right: 36.0),
              )
            ],
          )
        ],
      ),
    );
  }
}
