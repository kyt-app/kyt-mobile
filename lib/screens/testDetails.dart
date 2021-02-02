import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/screens/navigation.dart';
import 'package:kyt/screens/upload.dart';
import 'package:kyt/widgets/card.dart';
import 'package:url_launcher/url_launcher.dart';

import 'upload.dart';

Future<String> getTestDetails(String testName, String email) async {
  final testDetailsEndpoint = Uri.parse(
      'https://kyt-api.azurewebsites.net/tests/testdetails?email=$email&testName=$testName');
  final response = await http.get(testDetailsEndpoint);

  if (response.statusCode == 200) {
    return response.body;
  }

  return null;
}

Future<String> deleteTest(String testName, String email) async {
  final http.Response response = await http.post(
    'https://kyt-api.azurewebsites.net/tests/deletetest',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String>{"email": email, "testName": testName}),
  );

  if (response.statusCode == 200) {
    print(response.body);
    return response.body;
  }

  return null;
}

class TestDetails extends StatefulWidget {
  static String id = "testDetails";
  final String test;

  TestDetails({this.test});

  @override
  _TestDetails createState() => _TestDetails(test: test);
}

class _TestDetails extends State<TestDetails> {
  final user = FirebaseAuth.instance.currentUser;
  final String test;

  _TestDetails({this.test});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTestDetails(test, user.email),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                    backgroundColor: MyColors.darkPrimary,
                    title: Text('Test details')),
                body: Center(child: CircularProgressIndicator()));
          }

          final details = json.decode(snapshot.data);

          return Scaffold(
            backgroundColor: MyColors.offWhite,
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Future<String> res =
                        deleteTest(details['testName'], user.email);
                    print(res);
                    Navigator.pushNamed(context, Navigation.id);
                  },
                )
              ],
              backgroundColor: MyColors.darkPrimary,
              title: Text('Test details'),
            ),
            body: Container(
              margin: EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                      child: Ink(
                          decoration: ShapeDecoration(
                              color: details['status'] == 'valid'
                                  ? MyColors.green
                                  : Colors.red,
                              shape: CircleBorder()),
                          child: Icon(
                              details['status'] == 'valid'
                                  ? Icons.check
                                  : Icons.clear,
                              color: Colors.white,
                              size: 100.0
                          )
                      )
                  ),
                  MySpaces.vGapInBetween,
                  Center(
                    child: Text(details['testName'],
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: MyColors.darkPrimary)),
                  ),
                  MySpaces.vMediumGapInBetween,
                  Text(
                    'Date issued',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: MyColors.darkPrimary),
                  ),
                  MySpaces.vGapInBetween,
                  VerifyCard(
                    text: DateFormat.MMMMEEEEd('en_US')
                        .format(DateTime.parse(details['timestamp'])),
                  ),
                  MySpaces.vMediumGapInBetween,
                  Text(
                    'Valid until',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: MyColors.darkPrimary),
                  ),
                  MySpaces.vGapInBetween,
                  VerifyCard(
                    // keep validity for 3 days after the issuing date
                    text: !details['testName'].toString().contains('vaccine')
                        ? '${DateFormat.MMMMEEEEd('en_US').format(DateTime.fromMillisecondsSinceEpoch(DateTime.parse(details['timestamp']).millisecondsSinceEpoch + 259200000))}'
                        : 'No expiry date'
                  ),
                  MySpaces.vLargeGapInBetween,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      details['status'] == 'invalid'
                          ? ButtonTheme(
                              minWidth: 100.0,
                              child: RaisedButton(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6.0))),
                                padding: EdgeInsets.all(14.0),
                                color: MyColors.darkPrimary,
                                child: Text('Re-verify',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: MyColors.white)),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          Upload(details['testName'])));
                                },
                              ),
                            )
                          : SizedBox(width: 0.0),
                      SizedBox(width: 10.0),
                      ButtonTheme(
                        minWidth: 100.0,
                        child: RaisedButton(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                          padding: EdgeInsets.all(14.0),
                          color: MyColors.darkPrimary,
                          child: Text(
                              'View report',
                              style: Theme.of(context).textTheme.subtitle1.copyWith(color: MyColors.white)
                          ),
                          onPressed: () async {
                            if (await canLaunch(details['imageUrl'])) {
                              launch(details['imageUrl']);
                            } else {
                              throw 'Couldn\'t launch ${details['imageUrl']}';
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
