import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/testCard.dart';

Future<String> getUserTests(String email) async {
  final updateStatusEndpoint =
      Uri.parse('https://kyt-api.azurewebsites.net/update/status?email=$email');
  final response = await http.get(updateStatusEndpoint);
  if (response.statusCode == 200) {
    print(response.body);
    final testsEndpoint =
        Uri.parse('https://kyt-api.azurewebsites.net/profile?email=$email');
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
        future: getUserTests(user.email),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: MyColors.offWhite,
                body: Center(child: CircularProgressIndicator()));
          }

          final userProfile = json.decode(snapshot.data);

          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: MyColors.offWhite,
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      color: MyColors.darkPrimary,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      padding: EdgeInsets.all(MyDimens.double_40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(MyDimens.double_200),
                            child: Image.network(
                              '${userProfile['pfp']}',
                              height: 100.0,
                              width: 100.0,
                            ),
                          ),
                          MySpaces.vGapInBetween,
                          Text(
                            'Rachit Gupta',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(
                                    color: MyColors.white,
                                    fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                  Container(
                      child: Container(
                    margin: EdgeInsets.all(MyDimens.double_30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            child: Text(
                              'Health care records',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      color: MyColors.darkPrimary,
                                      fontWeight: FontWeight.normal),
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
                                return TestCard(
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
          );
        });
  }
}

// ${userProfile['name']}
/*
Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage('${userProfile['pfp']}')
                          ),
                        ),
                      ),*/
