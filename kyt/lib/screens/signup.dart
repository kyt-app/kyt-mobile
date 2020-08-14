import 'package:flutter/material.dart';
import 'package:kyt/functions/database.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/screens/login.dart';
import 'package:kyt/widgets/authTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:kyt/screens/home.dart';
import 'package:kyt/functions/getAadhar.dart' as getAadhar;

class Signup extends StatefulWidget {
  static String id = "signup";

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _auth = FirebaseAuth.instance;
  String userName;
  String userEmail;
  String userAadhar;
  String userPhoneNumber;
  String userPassword;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          color: MyColors.offWhite,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    MyStrings.signupForKYT,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.w600, color: MyColors.black),
                  ),
                  MySpaces.vMediumGapInBetween,
                  Container(
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AuthTextField(
                              onChanged: (value) {
                                userName = value;
                              },
                              password: false,
                              hint: MyStrings.nameLabel,
                            ),
                            MySpaces.vGapInBetween,
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
                              maxLength: 12,
                              onChanged: (value) {
                                userAadhar = value;
                                var Aadhar = getAadhar.GetAadhar();
                                Aadhar.setAadhar(userAadhar);
                              },
                              password: false,
                              hint: MyStrings.aadharNumberLabel,
                            ),
                            MySpaces.vGapInBetween,
                            AuthTextField(
                              maxLength: 10,
                              onChanged: (value) {
                                userPhoneNumber = value;
                              },
                              password: false,
                              hint: MyStrings.phoneNumberLabel,
                            ),
                            MySpaces.vGapInBetween,
                            AuthTextField(
                              onChanged: (value) {
                                userPassword = value;
                              },
                              password: true,
                              hint: MyStrings.passwordLabel,
                            ),
                            MySpaces.vSmallGapInBetween,
                            RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              padding: EdgeInsets.all(14),
                              color: MyColors.darkPrimary,
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: userEmail,
                                          password: userPassword);

                                  //create a new document for the user
                                  await DatabaseService(uid: userAadhar)
                                      .updateUserData(userName, userPhoneNumber,
                                          userAadhar);

                                  if (newUser != null) {
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
                                    MyStrings.createNewAccountLabel,
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
                                  MyStrings.alreadyAnAccountLabel,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Text(" "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, Login.id);
                                  },
                                  child: Text(
                                    MyStrings.loginLabel + ".",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: MyColors.green),
                                  ),
                                )
                              ],
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
      ),
    );
  }
}
