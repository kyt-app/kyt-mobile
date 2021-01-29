import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/screens/verification/1.dart';
import 'package:kyt/widgets/verificationCard.dart';
import 'verification/2.dart';
import 'verification/3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  static String id = "home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void getCurrentUserId() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final uid = user.uid;
    print(uid);
  }

  List medicalRecords;
  String covidVaccine;
  String name;

  @override
  void initState() {
    super.initState();
    fetchJsonData();
    getCurrentUserId();
  }

  void fetchJsonData() async {
    var url = 'https://knowyourtraveller.herokuapp.com/api/users/123456789012';
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = response.body;
      var name = json.decode(jsonResponse)['name'];
      var medicalRecords =
          json.decode(jsonResponse)['medicalRecords']['covidVaccine'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkPrimary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: Text(
              MyStrings.travellerLabel,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: MyColors.lightGrey),
            ),
          ),
          MySpaces.vSmallGapInBetween,
          Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.asset(
                  'assets/icons/avi.jpg',
                  width: 110.0,
                  height: 110.0,
                  fit: BoxFit.fill,
                ),
              ),
              MySpaces.vSmallGapInBetween,
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: MyColors.offWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            MyStrings.sampleName,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: MyColors.darkPrimary,
                                    fontWeight: FontWeight.bold),
                          ),
                          MySpaces.vLargeGapInBetween,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                MyStrings.verificationLabel,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              MySpaces.vGapInBetween,
                              VerificationCard(
                                iconBool: true,
                                route: Verification1.id,
                                text: MyStrings.test1Label,
                              ),
                              MySpaces.vSmallGapInBetween,
                              VerificationCard(
                                iconBool: false,
                                route: Verification2.id,
                                text: MyStrings.test2Label,
                              ),
                              MySpaces.vSmallGapInBetween,
                              VerificationCard(
                                iconBool: false,
                                route: Verification3.id,
                                text: MyStrings.test3Label,
                              ),
                              MySpaces.vSmallGapInBetween,
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.75,
              ),
            ],
          )
        ],
      ),
    );
  }
}
