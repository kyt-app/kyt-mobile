import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/screens/home.dart';
import 'package:kyt/screens/signup.dart';
import 'package:kyt/widgets/authTextField.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  static String id = "login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail;
  String userPassword;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: MyColors.offWhite,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  MyStrings.loginToKYT,
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      fontWeight: FontWeight.w600, color: MyColors.darkPrimary),
                ),
                MySpaces.vMediumGapInBetween,
                Container(
                  child: Column(
                    children: <Widget>[
                      AuthTextField(
                        onChanged: (value) {
                          userEmail = value;
                        },
                        inputType: TextInputType.emailAddress,
                        password: false,
                        hint: MyStrings.emailAddressLabel,
                      ),
                      MySpaces.vGapInBetween,
                      AuthTextField(
                        onChanged: (value) {
                          userPassword = value;
                        },
                        password: true,
                        hint: MyStrings.passwordLabel,
                      ),
                      MySpaces.vMediumGapInBetween,
                      RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        padding: EdgeInsets.all(14),
                        color: MyColors.darkPrimary,
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            final user = await _auth.signInWithEmailAndPassword(
                                email: userEmail, password: userPassword);
                            if (user != null) {
                              Navigator.pushNamed(context, Home.id);
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              MyStrings.loginLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: MyColors.white),
                            ),
                          ],
                        ),
                      ),
                      MySpaces.vMediumGapInBetween,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            MyStrings.noAccountLabel,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(" "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Signup.id);
                            },
                            child: Text(
                              MyStrings.signupLabel + ".",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: MyColors.green),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
