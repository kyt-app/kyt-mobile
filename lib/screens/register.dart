import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:kyt/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<bool> passportCheckIfExists(String passportNumber) async {
  final endpoint = Uri.parse('https://kyt-api.azurewebsites.net/users/register/checkpassport?passportNumber=$passportNumber');
  final response = await http.get(endpoint);

  if (response.statusCode == 200) {
    return json.decode(response.body)['boolean'];
  }

  return null;
}

class Register extends StatefulWidget {
  static String id = "register";
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  final _storage = firebase_storage.FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  String userName, userEmail, phoneNumber, userCountry, userPassportNumber, userPassword, userPfpPath, userPfpUrl;
  int kytNumber;
  List<String> countries = ['India', 'USA'];
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) => ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            color: MyColors.offWhite,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      MyStrings.registerForKYT,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.w600, color: MyColors.black),
                    ),
                    MySpaces.vMediumGapInBetween,
                    Container(
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  counter: Container(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.grey[800]),
                                  hintText: MyStrings.nameLabel,
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                                  ),
                                ),
                                validator: (String name) { return name.isEmpty ? 'Name is required' : null; },
                                onSaved: (String name) { userName = name; },
                              ),
                              MySpaces.vGapInBetween,
                              TextFormField(
                                decoration: InputDecoration(
                                  counter: Container(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.grey[800]),
                                  hintText: MyStrings.emailAddressLabel,
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (String email) {
                                  RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                                  if (!emailRegex.hasMatch(email)) {
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.emailError)));
                                    return MyStrings.emailError;
                                  }
                                  return null;
                                },
                                onSaved: (String email) { userEmail = email; },
                              ),
                              MySpaces.vGapInBetween,
                              TextFormField(
                                decoration: InputDecoration(
                                  counter: Container(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.grey[800]),
                                  hintText: MyStrings.phoneNumberLabel,
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (String phone) {
                                  if (phone.isEmpty) {
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.phoneNumberError)));
                                    return MyStrings.phoneNumberError;
                                  }
                                  return null;
                                },
                                onSaved: (String phone) { phoneNumber = phone; },
                              ),
                              MySpaces.vGapInBetween,
                              DropdownButton(
                                isExpanded: true,
                                value: userCountry,
                                items: countries.map((country) {
                                  return DropdownMenuItem(
                                      value: country,
                                      child: Text(country)
                                  );
                                }).toList(),
                                onChanged: (country) {
                                  setState(() {
                                    userCountry = country;
                                  });
                                },
                              ),
                              MySpaces.vGapInBetween,
                              TextFormField(
                                decoration: InputDecoration(
                                  counter: Container(),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                                  ),
                                  hintStyle: Theme.of(context).textTheme.headline6.copyWith(color: Colors.grey[800]),
                                  hintText: MyStrings.passportLabel,
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                onSaved: (String passport) { userPassportNumber = passport; },
                                validator: (String passport) {
                                  if (userCountry == 'India') {
                                    RegExp indianPassport = RegExp(r"^[A-PR-WYa-pr-wy][1-9]\d{5}[1-9]$");
                                    if (!indianPassport.hasMatch(passport)) {
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.passportNumberError)));
                                      return MyStrings.passportNumberError;
                                    }
                                    return null;
                                  } else {
                                    RegExp usPassport = RegExp(r"^(?!(0))[a-zA-Z0-9]{6,9}$");
                                    if (!usPassport.hasMatch(passport)) {
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.passportNumberError)));
                                      return MyStrings.passportNumberError;
                                    }
                                    return null;
                                  }
                                },
                              ),
                              MySpaces.vGapInBetween,
                              TextFormField(
                                decoration: InputDecoration(
                                  counter: Container(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.grey[800]),
                                  hintText: MyStrings.passwordLabel,
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                                  ),
                                ),
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (String password) {
                                  if (password.isEmpty) {
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.passwordRequiredError)));
                                    return MyStrings.passwordRequiredError;
                                  }
                                  return null;
                                },
                                onSaved: (String password) { userPassword = password; },
                              ),
                              MySpaces.vGapInBetween,
                              RaisedButton(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                padding: EdgeInsets.all(14.0),
                                color: MyColors.darkPrimary,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          'Upload PFP',
                                          style: Theme.of(context).textTheme.headline6.copyWith(color: MyColors.white)
                                      )
                                    ]
                                ),
                                onPressed: () async {
                                  final pfpImage = await ImagePicker.pickImage(source: ImageSource.gallery);
                                  userPfpPath = pfpImage.path;
                                  print(pfpImage.path);
                                },
                              ),
                              MySpaces.vSmallGapInBetween,
                              RaisedButton(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                padding: EdgeInsets.all(14.0),
                                color: MyColors.darkPrimary,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                        MyStrings.createNewAccountLabel,
                                        style: Theme.of(context).textTheme.headline6.copyWith(color: MyColors.white)
                                    )
                                  ]
                                ),
                                onPressed: () async {
                                  _formKey.currentState.save();

                                  if (_formKey.currentState.validate()) {
                                    FocusScope.of(context).unfocus();

                                    final passportExists = await passportCheckIfExists(userPassportNumber);
                                    
                                    if (!passportExists) {
                                      print(MyStrings.registeringLabel);
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(MyStrings.registeringLabel + userName)));

                                      // firebase auth
                                      final newUser = await _auth.createUserWithEmailAndPassword(email: userEmail, password: userPassword);

                                      if (userPfpPath != null) {
                                        final File userPfp = File(userPfpPath);
                                        firebase_storage.UploadTask userPfpUploadTask = _storage.ref('$userEmail/pfp/${basename(userPfpPath)}').putFile(userPfp);

                                        try {
                                          firebase_storage.TaskSnapshot snapshot = await userPfpUploadTask;
                                          // get download url of uploaded image
                                          userPfpUrl = await _storage.ref('$userEmail/pfp/${basename(userPfpPath)}').getDownloadURL();
                                          print('uploaded pfp.');
                                          print(userPfpUrl);
                                        } catch (e) {
                                          print(userPfpUploadTask.snapshot);
                                        }
                                      } else {
                                        // random placeholder pfp
                                        userPfpUrl = 'https://i.imgur.com/twPSMdV.jpg';
                                      }

                                      // generate unique kytNumber
                                      kytNumber = 100000 + Random().nextInt(999999 - 100000);

                                      // push user details to db
                                      final http.Response response = await http.post(
                                        'https://kyt-api.azurewebsites.net/users/register',
                                        headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8' },
                                        body: jsonEncode(<String, String>{
                                          'name': userName,
                                          'phoneNumber': phoneNumber,
                                          'email': userEmail,
                                          'country': userCountry,
                                          'passportNumber': userPassportNumber,
                                          'kytNumber': kytNumber.toString(),
                                          'pfpUrl': userPfpUrl
                                        }),
                                      );

                                      if (newUser != null) {
                                        Navigator.pushNamed(context, Login.id);
                                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Registration successful. Welcome aboard!')));
                                      }

                                      if (response.statusCode == 201) {
                                        return print('Reg done');
                                      } else {
                                        print("Reg failed.");
                                        throw Exception('Failed to create user.');
                                      }

                                    } else {
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('The entered passport number is already registered with a different account.')));
                                    }
                                  }
                                },
                              ),
                              MySpaces.vMediumGapInBetween,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    MyStrings.alreadyAnAccountLabel,
                                    style: Theme.of(context).textTheme.subtitle1
                                  ),
                                  Text(" "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, Login.id);
                                    },
                                    child: Text(
                                      MyStrings.loginLabel + '.',
                                      style: Theme.of(context).textTheme.subtitle1.copyWith(color: MyColors.green)
                                    )
                                  )
                                ],
                              )
                            ],
                          )
                      )
                    )
                  ],
                ),
              )
            )
          )
        ),
      )
    );
  }
}
