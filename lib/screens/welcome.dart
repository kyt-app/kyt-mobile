import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/screens/login.dart';
import 'package:kyt/screens/register.dart';
import 'package:kyt/screens/navigation.dart';

Future loadUser(context) async {
  FirebaseAuth.instance.authStateChanges().listen((User user) {
    if (user != null) {
      Navigator.pushNamed(context, Navigation.id);
    }
  });
}

class Welcome extends StatefulWidget {
  static String id = "welcome";
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadUser(context),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: MyColors.darkPrimary,
            body: Semantics(
              label: "Welcome screen",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 170),
                    child: Column(
                      children: <Widget>[
                        Text(
                          MyStrings.appNameUppercase,
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              color: MyColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        MySpaces.vGapInBetween,
                        Text(
                          MyStrings.tagline,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: MyColors.lightGrey),
                        )
                      ],
                    ),
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            MyStrings.joinKytLabel,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: MyColors.darkPrimary,
                                    fontWeight: FontWeight.bold),
                          ),
                          MySpaces.vLargeGapInBetween,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Login.id);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  color: MyColors.darkPrimary,
                                  padding: EdgeInsets.all(18),
                                  child: Text(
                                    MyStrings.loginLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(color: MyColors.white),
                                  ),
                                ),
                              ),
                              MySpaces.vGapInBetween,
                              Text(
                                MyStrings.or,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              MySpaces.vGapInBetween,
                              ButtonTheme(
                                minWidth: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Register.id);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  color: MyColors.darkPrimary,
                                  padding: EdgeInsets.all(18),
                                  child: Text(
                                    MyStrings.createNewAccountLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(color: MyColors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.45,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
