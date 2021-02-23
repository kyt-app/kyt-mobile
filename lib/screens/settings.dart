import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/functions/showSignoutConfirmation.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/screens/editProfile.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: Semantics(
        label: "Settings",
        child: Column(
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
              icon: Icons.archive,
              label: 'Archived reports',
              onPressed: () {
                Navigator.of(context).push(
                    // TODO: create screen named ArchivedReports()
                    MaterialPageRoute(builder: (context) => ReportABug()));
              },
            ),
            SettingsRow(
              icon: Icons.edit,
              label: 'Edit Profile',
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditProfile()));
              },
            ),
            SettingsRow(
              icon: Icons.report,
              label: 'Report a bug',
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReportABug()));
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
                        showSignoutConfirmation(context, auth);
                      },
                    ),
                  ),
                  padding: EdgeInsets.only(right: 36.0),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
