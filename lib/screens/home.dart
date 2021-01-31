import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
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
      resizeToAvoidBottomPadding: true,
      backgroundColor: MyColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                color: MyColors.darkPrimary,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.3,
                padding: EdgeInsets.all(MyDimens.double_50),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage('https://github.com/rchtgpt.png'),
                    ),
                  ),
                ),

              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: MyDimens.double_30, vertical: MyDimens.double_15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      MyStrings.sampleName + "'s Healthcare Records",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(
                          color: MyColors.darkPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    MySpaces.vLargeGapInBetween,
                    Container(
                      child: Column(
                        children: [
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
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
