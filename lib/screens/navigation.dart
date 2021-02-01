import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/screens/home.dart';
import 'package:kyt/screens/qrCode.dart';
import 'package:kyt/screens/settings.dart';
import 'package:navigation_action_bar/navigation_action_bar.dart';

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
  int firstIconColorInt = 1;
  int secondIconColorInt = 0;
  List _currentPage = [Home(), QRCode(), Settings()];
  double currentIndex = 0;

  Future<String> getTextFromOCR(List<int> imageBytes) async {
    final ocrEndpoint = Uri.parse(
        'https://kyt-app-ocr.cognitiveservices.azure.com/vision/v3.1/ocr');
    final azureResponse = await http.post(ocrEndpoint,
        headers: <String, String>{
          'Ocp-Apim-Subscription-Key': 'b583a5bb13ff448399982684386e48ac',
          'Content-Type': 'application/octet-stream'
        },
        body: imageBytes);

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
    final String validationEndpoint =
        'https://kyt-api.azurewebsites.net/verify';
    final validationResponse =
        await http.post(validationEndpoint, body: <String, String>{
      'email': email,
      'testName': testName,
      'timestamp': '${DateTime.now()}',
      'text': text
    });

    if (validationResponse.statusCode == 200) {
      bool valid = json.decode(validationResponse.body)['boolean'];
      return valid;
    }

    print('nothing happened thus returning false');
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            'An unknown error occurred. We were unable to verify the test.')));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // takePicture() async {
    //   Navigator.of(context, rootNavigator: true).pop(); // clears dialog box
    //   final imageFromCamera =
    //       await ImagePicker.pickImage(source: ImageSource.camera);
    //   final imageBytes = imageFromCamera.readAsBytesSync();
    //   String ocrText = await getTextFromOCR(imageBytes);
    //   validTest = await validateText(ocrText, user.email, testName);
    //   print('camera intent valid test result: $validTest');
    //
    //   !validTest
    //       ? Scaffold.of(context).showSnackBar(SnackBar(
    //           content: Text(
    //               'We couldn\'t verify your test results. Please try again.')))
    //       : Scaffold.of(context).showSnackBar(SnackBar(
    //           content:
    //               Text('Valid test result uploaded. You\'re good to go!')));
    // }
    //
    // chooseFromGallery() async {
    //   Navigator.of(context, rootNavigator: true).pop(); // clears dialog box
    //   final imageFromGallery =
    //       await ImagePicker.pickImage(source: ImageSource.gallery);
    //   final imageBytes = imageFromGallery.readAsBytesSync();
    //   String ocrText = await getTextFromOCR(imageBytes);
    //   validTest = await validateText(ocrText, user.email, testName);
    //   print('gallery intent valid test result: $validTest');
    //
    //   !validTest
    //       ? Scaffold.of(context).showSnackBar(SnackBar(
    //           content: Text(
    //               'We couldn\'t verify your test results. Please try again.')))
    //       : Scaffold.of(context).showSnackBar(SnackBar(
    //           content:
    //               Text('Valid test result uploaded. You\'re good to go!')));
    // }
    //
    // List cameraFunctions = [takePicture(), chooseFromGallery()];

    return Scaffold(
        backgroundColor: MyColors.offWhite,
        body: Container(
          child: _currentPage[currentIndex.toInt()],
          //   child: Center(

          //   ),
        ),
        bottomNavigationBar: NavigationActionBar(
          context: context,
          scaffoldColor: MyColors.offWhite,
          index: 0,
          backgroundColor: MyColors.darkPrimary,
          accentColor: Color(0xFAD3D3D3),
          subItems: [
            NavBarItem(iconData: Icons.photo, size: 25),
            NavBarItem(iconData: Icons.camera_alt, size: 25),
          ],
          mainIndex: 2,
          items: [
            NavBarItem(
                iconData: Icons.home,
                size: 25,
                unselectedColor: Color(0xFAD3D3D3),
                selectedColor: MyColors.white),
            NavBarItem(
                iconData: Icons.qr_code,
                size: 25,
                unselectedColor: Colors.white54,
                selectedColor: MyColors.white),
            NavBarItem(
                iconData: Icons.add,
                size: 40,
                unselectedColor: Colors.white54,
                selectedColor: MyColors.white),
            NavBarItem(
                iconData: Icons.settings,
                size: 25,
                unselectedColor: Colors.white54,
                selectedColor: MyColors.white),
            NavBarItem(
                iconData: Icons.report,
                size: 25,
                unselectedColor: Colors.white54,
                selectedColor: MyColors.white),
          ],
          onTap: (index) {
            setState(() {
              print(index);
              if (index == 2) {
                currentIndex = currentIndex;
              } else if (index > 2) {
                currentIndex = index - 1;
              } else {
                currentIndex = index;
              }
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}
/*
AlertDialog(
                  content: SingleChildScrollView(
                      child: ListBody(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Verify your tests',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MyColors.darkPrimary)),
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
                            borderSide: BorderSide(
                                color: MyColors.darkGrey, width: 1.0),
                          ),
                        ),
                      )
                    ],
                  ),
                  MySpaces.vGapInBetween,
                  GestureDetector(
                      child: Text('Take a picture'),
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // clears dialog box
                        final imageFromCamera = await ImagePicker.pickImage(
                            source: ImageSource.camera);
                        final imageBytes = imageFromCamera.readAsBytesSync();
                        String ocrText = await getTextFromOCR(imageBytes);
                        validTest =
                            await validateText(ocrText, user.email, testName);
                        print('camera intent valid test result: $validTest');

                        !validTest
                            ? Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'We couldn\'t verify your test results. Please try again.')))
                            : Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Valid test result uploaded. You\'re good to go!')));
                      }),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text('Choose from gallery'),
                    onTap:
                    },
                  )
                ],
              )))
*/
