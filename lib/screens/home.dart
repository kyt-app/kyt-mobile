import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
                appBar: AppBar(
                    backgroundColor: MyColors.darkPrimary, title: Text('Home')),
                body: Center(child: CircularProgressIndicator()));
          }

          final userProfile = json.decode(snapshot.data);

          return Scaffold(
            backgroundColor: MyColors.offWhite,
            body: Container(
                child: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: MyColors.darkPrimary,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  padding: EdgeInsets.all(MyDimens.double_10),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('${userProfile['pfp']}'),
                      ),
                    ),
                  ),
                ),
                Container(
                    child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MyDimens.double_30,
                      vertical: MyDimens.double_15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            '${userProfile['name']}\'s\nHealth-care records',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    color: MyColors.darkPrimary,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        MySpaces.vSmallGapInBetween,
                        Container(
                          height: 250.0,
                          child: ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            shrinkWrap: true,
                            itemCount: userProfile['tests'].length,
                            itemBuilder: (context, index) {
                              final test = userProfile['tests'][index];
                              return TestCard(
                                  iconBool:
                                      test['status'] == 'valid' ? true : false,
                                  text: test['testName']);
                            },
                          ),
                        ),
                      ]),
                )),
              ],
            ))),
          );
        });
  }
}
