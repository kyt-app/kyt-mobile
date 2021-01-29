import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:http/http.dart' as http;

class Upload extends StatefulWidget {
  static String id = "upload";

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _auth = FirebaseAuth.instance;
  String imagePath, testName;
  bool validTest;

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
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Verify your tests',
                  style: Theme.of(context).textTheme.headline5.copyWith(
                  fontWeight: FontWeight.w600, color: MyColors.darkPrimary)
                ),
                MySpaces.vMediumGapInBetween,
                TextField(
                  onChanged: (value) {
                    testName = value;
                  },
                  decoration: InputDecoration(
                    counter: Container(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    hintStyle: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.grey[800]),
                    hintText: 'Test name',
                    fillColor: Colors.white54,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
                    ),
                  ),
                )
              ],
            ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: true,
              child: AlertDialog(
               content: SingleChildScrollView(
                 child: ListBody(
                   children: <Widget>[
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
