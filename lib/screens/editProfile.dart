import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  static String id = "editProfile";
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _auth = FirebaseAuth.instance;
  final _storage = firebase_storage.FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  bool showSpinner = false;
  bool showMessage = false;
  bool indicator = false;
  String message = "";
  String userName, userEmail, userPfpPath, userPfpUrl, phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: MyColors.darkPrimary,
          centerTitle: true,
          title: Text('Edit Profile',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: MyColors.white)),
        ),
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) => ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: Container(
                  color: MyColors.offWhite,
                  child: Center(
                      child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(
                                                    color: Colors.grey[800]),
                                            hintText: '${user.displayName}',
                                            fillColor: MyColors.offWhite,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: MyColors.darkGrey,
                                                  width: 2.0),
                                            ),
                                            enabled: false)),
                                    MySpaces.vGapInBetween,
                                    TextFormField(
                                        decoration: InputDecoration(
                                          counter: Container(),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                  color: Colors.grey[800]),
                                          hintText: '${user.email}',
                                          fillColor: MyColors.offWhite,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MyColors.darkGrey,
                                                width: 2.0),
                                          ),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        enabled: false),
                                    MySpaces.vGapInBetween,
                                    TextFormField(
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
                                        hintText: MyStrings.phoneNumberLabel,
                                        fillColor: MyColors.offWhite,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyColors.darkGrey,
                                              width: 2.0),
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (String phone) {
                                        if (phone.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  MyStrings.phoneNumberError),
                                            ),
                                          );
                                          return MyStrings.phoneNumberError;
                                        }
                                        return null;
                                      },
                                      onSaved: (String phone) {
                                        phoneNumber = phone;
                                      },
                                    ),
                                    MySpaces.vGapInBetween,
                                    RaisedButton(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                      padding: EdgeInsets.all(14.0),
                                      color: MyColors.darkPrimary,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('Change PFP',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .copyWith(
                                                        color: MyColors.white))
                                          ]),
                                      onPressed: () async {
                                        final pfpImage =
                                            // ignore: deprecated_member_use
                                            await ImagePicker.pickImage(
                                                source: ImageSource.gallery);
                                        userPfpPath = pfpImage.path;
                                        setState(() => {showMessage = true});
                                        setState(() => {
                                              message =
                                                  "Save profile to apply PFP change"
                                            });
                                      },
                                    ),
                                    MySpaces.vSmallGapInBetween,
                                    RaisedButton(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                      padding: EdgeInsets.all(14.0),
                                      color: MyColors.darkPrimary,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('Save profile',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .copyWith(
                                                        color: MyColors.white))
                                          ]),
                                      onPressed: () async {
                                        _formKey.currentState.save();

                                        if (_formKey.currentState.validate()) {
                                          FocusScope.of(context).unfocus();

                                          if (userPfpPath != null) {
                                            setState(
                                                () => {showMessage = true});
                                            setState(() => {indicator = true});
                                            setState(() =>
                                                {message = "Saving profile"});
                                            final File userPfp =
                                                File(userPfpPath);
                                            firebase_storage.UploadTask
                                                userPfpUploadTask = _storage
                                                    .ref(
                                                        '$userEmail/pfp/${basename(userPfpPath)}')
                                                    .putFile(userPfp);

                                            try {
                                              // get download url of uploaded image
                                              userPfpUrl = await _storage
                                                  .ref(
                                                      '$userEmail/pfp/${basename(userPfpPath)}')
                                                  .getDownloadURL();
                                              print('uploaded pfp.');
                                              print(userPfpUrl);
                                            } catch (e) {
                                              print(userPfpUploadTask.snapshot);
                                            }
                                            // update firebase auth user object
                                            final user = _auth.currentUser;
                                            await user.updateProfile(
                                                displayName:
                                                    '${user.displayName}',
                                                photoURL: userPfpUrl);
                                          }

                                          // update user details in db
                                          final http.Response response =
                                              await http.post(
                                            'https://kyt-api.azurewebsites.net/update/profile',
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json; charset=UTF-8'
                                            },
                                            body: jsonEncode(<String, String>{
                                              'authToken': '${user.uid}',
                                              'phoneNumber': phoneNumber,
                                              'pfpUrl': userPfpUrl
                                            }),
                                          );

                                          if (response.statusCode == 200) {
                                            print('profile updated');
                                            setState(() => {indicator = false});
                                            setState(() => {
                                                  message =
                                                      "Profile updated successfully"
                                                });
                                          }
                                        }
                                      },
                                    ),
                                    Container(
                                        height: 110,
                                        width: double.infinity,
                                        color: MyColors.offWhite,
                                        child: Center(
                                            child: Container(
                                                padding: EdgeInsets.all(16),
                                                color: MyColors.offWhite,
                                                child: Column(children: [
                                                  showMessage
                                                      ? Column(children: [
                                                          indicator
                                                              ? CircularProgressIndicator()
                                                              : MySpaces
                                                                  .vSmallGapInBetween,
                                                          MySpaces
                                                              .vSmallGapInBetween,
                                                          Text(message)
                                                        ])
                                                      : SizedBox(width: 0.0)
                                                ]))))
                                  ],
                                )))
                      ],
                    ),
                  )))),
        ));
  }
}
