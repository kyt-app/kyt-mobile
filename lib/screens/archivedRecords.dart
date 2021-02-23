import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class ArchivedRecords extends StatefulWidget {
  static String id = "archivedRecords";
  @override
  _ArchivedRecordsState createState() => _ArchivedRecordsState();
}

class _ArchivedRecordsState extends State<ArchivedRecords> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserTests(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: MyColors.offWhite,
            body: Center(child: CircularProgressIndicator())
          );
        }

        final userProfile = json.decode(snapshot.data);
        List<Map<String, dynamic>> archivedTests = new List<Map<String, dynamic>>();
        userProfile['tests'].forEach((test) => {
          if (test['archived']) {
            archivedTests.add(test)
          }
        });

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: MyColors.offWhite,
          body: Container(
            child: Semantics(
              label: "Archived reports",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Archived healthcare records'.toUpperCase(),
                              style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: MyColors.darkPrimary,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          MySpaces.vGapInBetween,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                                'We have archived all your medical records which have expired.',
                                style: TextStyle(fontSize: 14.0)
                            ),
                          ),
                          MySpaces.vGapInBetween,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                                'You can delete any record by clicking on the delete icon on the details page.',
                                style: TextStyle(fontSize: 14.0)
                            ),
                          ),
                          MySpaces.vGapInBetween,
                          Container(
                            height: 340.0,
                            child: ListView.builder(
                              padding: EdgeInsets.all(0.0),
                              shrinkWrap: true,
                              itemCount: archivedTests.length,
                              itemBuilder: (context, index) {
                                return TestCard(
                                  iconBool: archivedTests[index]['status'] == 'valid' ? true : false,
                                  text: archivedTests[index]['testName']
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          )
        );
      },
    );
  }
}
