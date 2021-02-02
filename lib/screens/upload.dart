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
import 'package:path/path.dart';
import '../widgets/settingsRow.dart';

Future<String> getTextFromOCR(List<int> imageBytes) async {
  final ocrEndpoint = Uri.parse('https://kyt-app-ocr.cognitiveservices.azure.com/vision/v3.1/ocr');
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

Future<bool> validateAndUploadData(String text, String email, String testName, String testImageUrl) async {
  final String validationEndpoint = 'https://kyt-api.azurewebsites.net/verify';
  final validationResponse = await http.post(
      validationEndpoint,
      body: <String, String>{
        'email': email,
        'testName': testName,
        'timestamp': '${DateTime.now()}',
        'text': text,
        'imageUrl': testImageUrl
      }
  );

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
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  bool validTest;
  String imagePath, testName;
  final user = FirebaseAuth.instance.currentUser;
  final _storage = firebase_storage.FirebaseStorage.instance;

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
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(
                    color: MyColors.darkPrimary,
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0
              ),
            ),
          ),
          MySpaces.vGapInBetween,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 38.0),
            child: TextFormField(
              decoration: InputDecoration(
                counter: Container(),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.grey[800]),
                hintText: 'Test name',
                fillColor: MyColors.offWhite,
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0)),
              ),
              validator: (String testName) {
                return testName.isEmpty ? 'Name is required' : null;
              },
              onChanged: (String test) {
                testName = test;
              },
            ),
          ),
          MySpaces.vGapInBetween,
          SettingsRow(
            label: 'Take picture',
            icon: Icons.camera_alt,
            onPressed: () async {
              if (testName == null) {
                return Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please enter the test name before proceeding.')));
              }
              // get image from camera
              final imageFromCamera = await ImagePicker.pickImage(source: ImageSource.camera);
              print('camera image path: ${imageFromCamera.path}');

              // initialize test image url
              String testImageUrl;

              // start firebase upload task
              firebase_storage.UploadTask testImageUploadTask = _storage.ref('${user.email}/tests/${basename(imageFromCamera.path)}').putFile(imageFromCamera);

              // push download url of uploaded image to testImageUrl string
              try {
                firebase_storage.TaskSnapshot snapshot = await testImageUploadTask;
                testImageUrl = await _storage.ref('${user.email}/tests/${basename(imageFromCamera.path)}').getDownloadURL();
                print('uploaded image url: $testImageUrl');
              } catch (e) {
                print(testImageUploadTask.snapshot);
              }

              print('starting to read bytes');

              // start azure vision ocr task
              final imageBytes = imageFromCamera.readAsBytesSync();
              String ocrText = await getTextFromOCR(imageBytes);

              print('ocr was completed');

              // push data to db and validate test result
              validTest = await validateAndUploadData(ocrText, user.email, testName, testImageUrl);
              print('camera intent valid test result: $validTest');

              // return response according to test result
              !validTest
                  ? Scaffold.of(context).showSnackBar(SnackBar(content: Text('The result uploaded is not authentic. You may be ineligible for travel.')))
                  : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Valid test result uploaded. You\'re good to go!')));
            }
          ),
          SettingsRow(
            label: 'Upload from gallery',
            icon: Icons.photo,
            onPressed: () async {
              if (testName == null) {
                return Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please enter the test name before proceeding.')));
              }
              // choose image from gallery
              final imageFromGallery = await ImagePicker.pickImage(source: ImageSource.gallery);
              print('gallery image path: ${imageFromGallery.path}');

              // initialize test image url
              String testImageUrl;

              // start firebase upload task
              firebase_storage.UploadTask testImageUploadTask = _storage.ref('${user.email}/tests/${basename(imageFromGallery.path)}').putFile(imageFromGallery);

              // push download url of uploaded image to testImageUrl string
              try {
                firebase_storage.TaskSnapshot snapshot = await testImageUploadTask;
                testImageUrl = await _storage.ref('${user.email}/tests/${basename(imageFromGallery.path)}').getDownloadURL();
                print('uploaded image: $testImageUrl');
              } catch (e) {
                print(testImageUploadTask.snapshot);
              }

              print('starting to read bytes');

              // start azure vision ocr task
              final imageBytes = imageFromGallery.readAsBytesSync();
              String ocrText = await getTextFromOCR(imageBytes);

              print('ocr was completed.');

              // push data to db and validate test result
              validTest = await validateAndUploadData(ocrText, user.email, testName, testImageUrl);
              print('gallery intent valid test result: $validTest');

              // return response to user according to test result
              !validTest
                  ? Scaffold.of(context).showSnackBar(SnackBar(content: Text('The result uploaded is not authentic. You may be ineligible for travel.')))
                  : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Valid test result uploaded. You\'re good to go!')));
            },
          ),
        ],
      ),
    );
  }
}

