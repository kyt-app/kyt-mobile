import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/screens/navigation.dart';
import 'package:kyt/screens/register.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Login extends StatefulWidget {
  static String id = "login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail, userPassword;
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: MyColors.offWhite,
          body: Builder(
            builder: (context) => ModalProgressHUD(
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
                            fontWeight: FontWeight.w600,
                            color: MyColors.darkPrimary),
                      ),
                      MySpaces.vMediumGapInBetween,
                      Container(
                        child: Column(
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      counter: Container(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(color: Colors.grey[800]),
                                      hintText: MyStrings.emailAddressLabel,
                                      fillColor: MyColors.offWhite,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MyColors.darkGrey,
                                            width: 2.0),
                                      ),
                                    ),
                                    validator: (String email) {
                                      if (userEmail.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    MyStrings.emailError)));
                                        setState(() {
                                          showSpinner = false;
                                        });
                                        return MyStrings.emailError;
                                      }
                                      return null;
                                    },
                                    onSaved: (String email) {
                                      userEmail = email;
                                    },
                                  ),
                                  MySpaces.vGapInBetween,
                                  TextFormField(
                                      obscureText: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      decoration: InputDecoration(
                                        counter: Container(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(color: Colors.grey[800]),
                                        hintText: MyStrings.passwordLabel,
                                        fillColor: MyColors.offWhite,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyColors.darkGrey,
                                              width: 2.0),
                                        ),
                                      ),
                                      validator: (String password) {
                                        if (userPassword.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(MyStrings
                                                      .passwordRequiredError)));
                                          setState(() {
                                            showSpinner = false;
                                          });
                                          return MyStrings
                                              .passwordRequiredError;
                                        }
                                        return null;
                                      },
                                      onSaved: (String password) {
                                        userPassword = password;
                                      }),
                                  MySpaces.vMediumGapInBetween,
                                  RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    padding: EdgeInsets.all(14),
                                    color: MyColors.darkPrimary,
                                    onPressed: () async {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      try {
                                        _formKey.currentState.save();
                                        if (_formKey.currentState.validate()) {
                                          FocusScope.of(context).unfocus();
                                          final user = await _auth
                                              .signInWithEmailAndPassword(
                                                  email: userEmail,
                                                  password: userPassword);
                                          if (user != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(MyStrings
                                                        .loggingInLabel)));
                                            Navigator.pushNamed(
                                                context, Navigation.id);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(MyStrings
                                                        .incorrectPasswordError)));
                                          }
                                          setState(() {
                                            showSpinner = false;
                                          });
                                        }
                                      } catch (e) {
                                        print(e);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(MyStrings
                                                    .somethingWentWrongError)));
                                        setState(() {
                                          showSpinner = false;
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    Navigator.pushNamed(context, Register.id);
                                  },
                                  child: Text(
                                    MyStrings.registerLabel + ".",
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
          ),
        ),
        onWillPop: () async => false);
  }
}
