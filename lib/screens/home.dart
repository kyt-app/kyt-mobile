import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/testCard.dart';
import 'package:kyt/widgets/userPictureAndName.dart';

Future<String> getUserTests(String authToken) async {
  final updateStatusEndpoint = Uri.parse(
      'https://kyt-api.azurewebsites.net/update/status?authToken=$authToken');
  final response = await http.get(updateStatusEndpoint);
  if (response.statusCode == 200) {
    final testsEndpoint = Uri.parse(
        'https://kyt-api.azurewebsites.net/profile?authToken=$authToken');
    final profileResponse = await http.get(testsEndpoint);

    if (profileResponse.statusCode == 200) {
      return profileResponse.body;
    }
  }

  return null;
}

class Home extends StatefulWidget {
  static String id = "home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserTests(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: MyColors.offWhite,
                body: Center(child: CircularProgressIndicator()));
          }

          final userProfile = json.decode(snapshot.data);

          return Scaffold(
            backgroundColor: MyColors.offWhite,
            body: Container(
              child: Semantics(
                label: "Home screen",
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    UserPictureAndName(user: user),
                    Container(
                        child: Container(
                      margin: EdgeInsets.all(MyDimens.double_30),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              child: Text(
                                'Healthcare records'.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                        color: MyColors.darkPrimary,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            MySpaces.vGapInBetween,
                            Container(
                              height: 350.0,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0.0),
                                shrinkWrap: true,
                                itemCount: userProfile['tests'].length,
                                itemBuilder: (context, index) {
                                  final test = userProfile['tests'][index];
                                  // render TestCard if it is not archived
                                  return test['archived']
                                      ? SizedBox(width: 0.0)
                                      : TestCard(
                                          iconBool: test['status'] == 'valid'
                                              ? true
                                              : false,
                                          text: test['testName']);
                                },
                              ),
                            ),
                          ]),
                    )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
