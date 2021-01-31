import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/screens/home.dart';
import 'package:kyt/screens/settings.dart';

class Navigation extends StatefulWidget {
  static String id = "navigation";

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final _auth = FirebaseAuth.instance;
  String imagePath, testName;
  bool validTest;
  int pageIndex = 0;
  int firstIconColorInt = 0;
  int secondIconColorInt = 1;
  List _currentPage = [Home(), Settings()];
  List _iconColors = [Colors.white54, MyColors.white];

  Future<String> getTextFromOCR(List<int> imageBytes) async {
    final ocrEndpoint = Uri.parse('https://kyt-app-ocr.cognitiveservices.azure.com/vision/v3.1/ocr');
    final azureResponse = await http.post(
        ocrEndpoint,
        headers: <String, String>{
          'Ocp-Apim-Subscription-Key': 'b583a5bb13ff448399982684386e48ac',
          'Content-Type': 'application/octet-stream'
        },
        body: imageBytes
    );

    String ocrText = '';

    if (azureResponse.statusCode == 200) {
      Map<String, dynamic> responseMap = json.decode(azureResponse.body);

      for (var region in responseMap['regions']) {
        for (var lines in region['lines']) {
          for (var words in lines['words']) {
            ocrText += words['text'] + ' ';
          }
        }
      }
    }

    return ocrText;
  }

  Future<bool> validateText(String text, String email, String testName) async {
    final String validationEndpoint = 'https://kyt-api.azurewebsites.net/verify';
    final validationResponse = await http.post(
        validationEndpoint,
        body: <String, String>{
          'email': email,
          'testName': testName,
          'timestamp': '${DateTime.now()}',
          'text': text
        }
    );

    if (validationResponse.statusCode == 200) {
      bool valid = json.decode(validationResponse.body)['boolean'];
      return valid;
    }

    print('nothing happened thus returning false');
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('An unknown error occurred. We were unable to verify the test.')));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: Container(
      child: _currentPage[pageIndex],
      //   child: Center(

      //   ),
      ),
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: MyDimens.double_60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MyDimens.double_60),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: _iconColors[firstIconColorInt],
                  ),
                  onPressed: () {
                    setState(() {
                      pageIndex = 0;
                      firstIconColorInt = 1;
                      secondIconColorInt = 0;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings,
                      color: _iconColors[secondIconColorInt]),
                  onPressed: () {
                    setState(() {
                      pageIndex = 1;
                      firstIconColorInt = 0;
                      secondIconColorInt = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          color: MyColors.darkPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:  Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: MyColors.darkPrimary,
          child: Icon(Icons.add, size: 35,),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: true,
              child: AlertDialog(
                  content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  'Verify your tests',
                                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontWeight: FontWeight.w600, color: MyColors.darkPrimary)
                              ),
                              MySpaces.vGapInBetween,
                              TextField(
                                onChanged: (value) {
                                  testName = value;
                                },
                                  style: TextStyle(
                                      fontSize: 16,
                                  ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.grey[800]),
                                  hintText: 'Test name',
                                  fillColor: MyColors.offWhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.darkGrey, width: 1.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                          MySpaces.vGapInBetween,
                          GestureDetector(
                              child: Text('Take a picture'),
                              onTap: () async {
                                Navigator.of(context, rootNavigator: true).pop(); // clears dialog box
                                final imageFromCamera = await ImagePicker.pickImage(source: ImageSource.camera);
                                final imageBytes = imageFromCamera.readAsBytesSync();
                                String ocrText = await getTextFromOCR(imageBytes);
                                validTest = await validateText(ocrText, user.email, testName);
                                print('camera intent valid test result: $validTest');

                                !validTest
                                    ? Scaffold.of(context).showSnackBar(SnackBar(content: Text('We couldn\'t verify your test results. Please try again.')))
                                    : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Valid test result uploaded. You\'re good to go!')));
                              }
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
                          GestureDetector(
                            child: Text('Choose from gallery'),
                            onTap: () async {
                              Navigator.of(context, rootNavigator: true).pop(); // clears dialog box
                              final imageFromGallery = await ImagePicker.pickImage(source: ImageSource.gallery);
                              final imageBytes = imageFromGallery.readAsBytesSync();
                              String ocrText = await getTextFromOCR(imageBytes);
                              validTest = await validateText(ocrText, user.email, testName);
                              print('gallery intent valid test result: $validTest');

                              !validTest
                                  ? Scaffold.of(context).showSnackBar(SnackBar(content: Text('We couldn\'t verify your test results. Please try again.')))
                                  : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Valid test result uploaded. You\'re good to go!')));
                            },
                          )
                        ],
                      )
                  )
              ),
            );
          },
        ),
      ),
    );
  }
}
