import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';

import '../widgets/settingsRow.dart';

class Upload extends StatefulWidget {
  static String id = "upload";
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  bool validTest;
  String imagePath, testName;
  final user = FirebaseAuth.instance.currentUser;

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

  chooseFromGallery() async {
    Navigator.of(context, rootNavigator: true).pop(); // clears dialog box
    final imageFromGallery =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    final imageBytes = imageFromGallery.readAsBytesSync();
    String ocrText = await getTextFromOCR(imageBytes);
    validTest = await validateText(ocrText, user.email, testName);
    print('gallery intent valid test result: $validTest');

    !validTest
        ? Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'We couldn\'t verify your test results. Please try again.')))
        : Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Valid test result uploaded. You\'re good to go!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(bottom: MyDimens.double_30),
              color: MyColors.darkPrimary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.all(MyDimens.double_40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MyDimens.double_200),
                    child: Image.network(
                      'https://github.com/rchtgpt.png',
                      height: 100.0,
                      width: 100.0,
                    ),
                  ),
                  MySpaces.vGapInBetween,
                  Text(
                    'Rachit Gupta',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: MyColors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          Padding(
            padding: EdgeInsets.only(left: 38.0),
            child: Text(
              'Add prescription'.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: MyColors.darkPrimary,
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
            ),
          ),
          MySpaces.vGapInBetween,
          SettingsRow(
            label: 'Take picture',
            icon: Icons.camera_alt,
            isUpload: false,
          ),
          SettingsRow(
            label: 'Upload from gallery',
            icon: Icons.photo,
            isUpload: true,
          ),
        ],
      ),
    );
  }
}

