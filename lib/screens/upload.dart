import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/screens/navigation.dart';
import 'package:path/path.dart';
import '../widgets/settingsRow.dart';

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

Future<bool> validateAndUploadData(
    String text, String email, String testName, String testImageUrl) async {
  final String validationEndpoint = 'https://kyt-api.azurewebsites.net/verify';
  final validationResponse =
      await http.post(validationEndpoint, body: <String, String>{
    'email': email,
    'testName': testName,
    'timestamp': '${DateTime.now()}',
    'text': text,
    'imageUrl': testImageUrl
  });

  if (validationResponse.statusCode == 200) {
    bool valid = json.decode(validationResponse.body)['boolean'];
    return valid;
  }

  print('nothing happened thus returning false');
  // return error in validating
  return false;
}

class Upload extends StatefulWidget {
  static String id = "upload";
  String something;
  Upload(this.something);
  @override
  _UploadState createState() => _UploadState(this.something);
}

class _UploadState extends State<Upload> {
  String something;
  _UploadState(this.something);

  bool validTest;
  String imagePath, testName;
  final user = FirebaseAuth.instance.currentUser;
  final _storage = firebase_storage.FirebaseStorage.instance;
  bool showProgress = false;
  String progressMessage = "";
  var msgController = TextEditingController();
  String result = "result";
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      '${user.photoURL}',
                      height: 100.0,
                      width: 100.0,
                    ),
                  ),
                  MySpaces.vGapInBetween,
                  Text(
                    '${user.displayName}',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: MyColors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          Padding(
            padding: EdgeInsets.only(left: 38.0),
            child: Text(
              'Add test result'.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: MyColors.darkPrimary,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),
            ),
          ),
          MySpaces.vGapInBetween,
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 38.0),
              child: something == 'nav'
                  ? TextFormField(
                      controller: msgController,
                      decoration: InputDecoration(
                        counter: Container(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.grey[800]),
                        hintText: 'Test name',
                        fillColor: MyColors.offWhite,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyColors.darkGrey, width: 2.0)),
                      ),
                      validator: (String testName) {
                        return testName.isEmpty ? 'Name is required' : null;
                      },
                      onChanged: (String test) {
                        testName = test;
                      },
                    )
                  : TextFormField(
                      controller: msgController,
                      decoration: InputDecoration(
                        counter: Container(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.grey[800]),
                        hintText: something,
                        fillColor: MyColors.offWhite,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyColors.darkGrey, width: 2.0)),
                      ),
                      validator: (String testName) {
                        return testName.isEmpty ? 'Name is required' : null;
                      },
                      enabled: false,
                    )),
          MySpaces.vGapInBetween,
          SettingsRow(
              label: 'Take picture',
              icon: Icons.camera_alt,
              onPressed: () async {
                if (testName == null) {
                  if (something == 'nav') {
                    return Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Please enter the test name before proceeding.')));
                  } else {
                    testName = something;
                  }
                }
                // get image from camera
                final imageFromCamera =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                print('camera image path: ${imageFromCamera.path}');

                setState(() {
                  showProgress = true;
                });

                // initialize test image url
                String testImageUrl;

                // start firebase upload task
                firebase_storage.UploadTask testImageUploadTask = _storage
                    .ref(
                        '${user.email}/tests/${basename(imageFromCamera.path)}')
                    .putFile(imageFromCamera);

                setState(() {
                  progressMessage = "Uploading to server";
                });

                // push download url of uploaded image to testImageUrl string
                try {
                  firebase_storage.TaskSnapshot snapshot =
                      await testImageUploadTask;
                  testImageUrl = await _storage
                      .ref(
                          '${user.email}/tests/${basename(imageFromCamera.path)}')
                      .getDownloadURL();
                  print('uploaded image url: $testImageUrl');
                } catch (e) {
                  print(testImageUploadTask.snapshot);
                }

                print('starting to read bytes');

                setState(() {
                  progressMessage = "Reading bytes";
                });

                // start azure vision ocr task
                final imageBytes = imageFromCamera.readAsBytesSync();
                setState(() {
                  progressMessage = "Running OCR";
                });
                String ocrText = await getTextFromOCR(imageBytes);

                print('ocr was completed');

                // push data to db and validate test result
                validTest = await validateAndUploadData(
                    ocrText, user.email, testName, testImageUrl);
                setState(() {
                  progressMessage = "Validating";
                });
                print('camera intent valid test result: $validTest');
                setState(() {
                  // set the progress indicator to true so it would not be visible
                  showProgress = false;
                });
                // return response according to test result
                !validTest
                    ? Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'The result uploaded is not authentic. You may be ineligible for travel.')))
                    : Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Valid test result uploaded. You\'re good to go!')));
              }),
          SettingsRow(
            label: 'Upload from gallery',
            icon: Icons.photo,
            onPressed: () async {
              if (testName == null) {
                if (something == 'nav') {
                  return Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Please enter the test name before proceeding.')));
                } else {
                  testName = something;
                }
              }
              // choose image from gallery
              final imageFromGallery =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              print('gallery image path: ${imageFromGallery.path}');

              setState(() {
                showProgress = true;
              });

              // initialize test image url
              String testImageUrl;

              // start firebase upload task
              firebase_storage.UploadTask testImageUploadTask = _storage
                  .ref('${user.email}/tests/${basename(imageFromGallery.path)}')
                  .putFile(imageFromGallery);

              setState(() {
                progressMessage = "Uploading to server";
              });

              // push download url of uploaded image to testImageUrl string
              try {
                firebase_storage.TaskSnapshot snapshot =
                    await testImageUploadTask;
                testImageUrl = await _storage
                    .ref(
                        '${user.email}/tests/${basename(imageFromGallery.path)}')
                    .getDownloadURL();
                print('uploaded image: $testImageUrl');
              } catch (e) {
                print(testImageUploadTask.snapshot);
              }

              print('starting to read bytes');

              setState(() {
                progressMessage = "Reading bytes";
              });

              // start azure vision ocr task
              final imageBytes = imageFromGallery.readAsBytesSync();
              setState(() {
                progressMessage = "Running OCR";
              });
              String ocrText = await getTextFromOCR(imageBytes);

              print('ocr was completed.');

              // push data to db and validate test result
              validTest = await validateAndUploadData(
                  ocrText, user.email, testName, testImageUrl);
              setState(() {
                progressMessage = "Validating";
              });
              print('gallery intent valid test result: $validTest');
              setState(() {
                // set the progress indicator to true so it would not be visible
                showProgress = false;
              });
              // return response to user according to test result
              if (!validTest) {
                msgController.clear();
                if (something == 'nav') {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'The result uploaded is not authentic. You may be ineligible for travel.')));
                } else {
                  setState(() {
                    showResult = true;
                    result =
                        "The result uploaded is not authentic. You may be ineligible for travel.";
                  });
                }
              } else {
                msgController.clear();
                if (something == 'nav') {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Valid test result uploaded. You\'re good to go!')));
                } else {
                  setState(() {
                    showResult = true;
                    result = "Valid test result uploaded. You\'re good to go!";
                  });
                }
              }
            },
          ),
          Container(
            height: 100,
            width: double.infinity,
            color: MyColors.offWhite,
            child: Center(
                // use ternary operator to decide when to show progress indicator
                child: showProgress
                    ? Container(
                        padding: EdgeInsets.all(16),
                        color: MyColors.offWhite,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getLoadingIndicator(),
                              _getText(progressMessage)
                            ]))
                    : null),
          ),
          showResult
              ? Container(
                  height: 100,
                  width: double.infinity,
                  color: MyColors.offWhite,
                  child: Center(
                      child: Container(
                          padding: EdgeInsets.all(16),
                          color: MyColors.offWhite,
                          child: Column(children: [Text(result)]))))
              : SizedBox(width: 0.0)
        ],
      ),
    );
  }

  Widget _getLoadingIndicator() {
    return Padding(
        child: Container(
            child: CircularProgressIndicator(strokeWidth: 3),
            width: 32,
            height: 32),
        padding: EdgeInsets.only(bottom: 16));
  }

  Widget _getText(String displayedText) {
    return Text(
      displayedText,
      style: TextStyle(color: MyColors.darkPrimary, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
