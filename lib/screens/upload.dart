import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyt/functions/getOCRLink.dart';
import 'package:kyt/functions/getTextFromOCR.dart';
import 'package:kyt/functions/testNameCheckIfExists.dart';
import 'package:kyt/functions/validateAndUploadData.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/userPictureAndName.dart';
import 'package:path/path.dart';

import '../widgets/settingsRow.dart';

class Upload extends StatefulWidget {
  static String id = "upload";
  final String something;
  Upload(this.something);
  @override
  _UploadState createState() => _UploadState(this.something);
}

class _UploadState extends State<Upload> {
  String testNameContext;
  _UploadState(this.testNameContext);

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
          UserPictureAndName(user: user),
          MySpaces.vMediumGapInBetween,
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
            child: testNameContext == 'nav'
                ? TestNameTextFormField(
                    messageController: msgController,
                    hintText: 'Test name',
                    onChanged: (String test) {
                      testName = test;
                    },
                  )
                : TestNameTextFormField(
                    messageController: msgController,
                    hintText: testNameContext,
                    isEnabled: false,
                  ),
          ),
          MySpaces.vGapInBetween,
          SettingsRow(
              label: 'Take picture',
              icon: Icons.camera_alt,
              onPressed: () async {
                if (testName == null) {
                  if (testNameContext == 'nav') {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please enter the test name before proceeding.'),
                      ),
                    );
                  } else {
                    testName = testNameContext;
                  }
                }

                if (testNameContext == 'nav') {
                  final testNameExists =
                      await testNameCheckIfExists(testName, '${user.uid}');
                  if (!testNameExists) {
                    // get image from camera
                    final imageFromCamera =
                        // ignore: deprecated_member_use
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
                      testImageUrl = await _storage
                          .ref(
                              '${user.email}/tests/${basename(imageFromCamera.path)}')
                          .getDownloadURL();
                      print('uploaded image url: $testImageUrl');
                    } catch (e) {
                      firebase_storage.TaskSnapshot snapshot =
                          await testImageUploadTask;
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

                    String resultsEndpoint = await getOCRLink(imageBytes);
                    String ocrText = '';

                    Timer(Duration(seconds: 2), () async {
                      ocrText = await getTextFromOCR(resultsEndpoint);

                      print('ocr was completed');

                      setState(() {
                        progressMessage = "Validating";
                      });

                      // push data to db and validate test result
                      validTest = await validateAndUploadData(
                          ocrText, user.uid, testName, testImageUrl);

                      print('camera intent valid test result: $validTest');
                      setState(() {
                        // set the progress indicator to true so it would not be visible
                        showProgress = false;
                      });
                      // return response according to test result
                      if (!validTest) {
                        msgController.clear();
                        if (testNameContext == 'nav') {
                          var snackBar = SnackBar(
                            content: Text(
                                'The result uploaded is not authentic. You may be ineligible for travel.'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          var snackBar = SnackBar(
                            content: Text(
                                'The result uploaded is not authentic. You may be ineligible for travel.'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        msgController.clear();
                        if (testNameContext == 'nav') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Valid test result uploaded. You\'re good to go!'),
                            ),
                          );
                        } else {
                          var snackBar = SnackBar(
                              content: Text(
                                  'Valid test result uploaded. You\'re good to go!'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    });
                  } else {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Test name already exists'),
                      ),
                    );
                  }
                } else {
                  // get image from camera
                  final imageFromCamera =
                      // ignore: deprecated_member_use
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
                    firebase_storage.TaskSnapshot snapshot =
                        await testImageUploadTask;
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

                  String resultsEndpoint = await getOCRLink(imageBytes);
                  String ocrText = '';

                  Timer(Duration(seconds: 2), () async {
                    ocrText = await getTextFromOCR(resultsEndpoint);

                    print('ocr was completed');

                    setState(() {
                      progressMessage = "Validating";
                    });

                    // push data to db and validate test result
                    validTest = await validateAndUploadData(
                        ocrText, user.uid, testName, testImageUrl);

                    print('camera intent valid test result: $validTest');
                    setState(() {
                      // set the progress indicator to true so it would not be visible
                      showProgress = false;
                    });
                    // return response according to test result
                    if (!validTest) {
                      msgController.clear();
                      if (testNameContext == 'nav') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'The result uploaded is not authentic. You may be ineligible for travel.'),
                          ),
                        );
                      } else {
                        var snackBar = SnackBar(
                            content: Text(
                                'The result uploaded is not authentic. You may be ineligible for travel.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    } else {
                      msgController.clear();
                      if (testNameContext == 'nav') {
                        var snackBar = SnackBar(
                          content: Text(
                              'Valid test result uploaded. You\'re good to go!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        var snackBar = SnackBar(
                          content: Text(
                              'Valid test result uploaded. You\'re good to go!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  });
                }
              }),
          SettingsRow(
            label: 'Upload from gallery',
            icon: Icons.photo,
            onPressed: () async {
              if (testName == null) {
                if (testNameContext == 'nav') {
                  return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please enter the test name before proceeding.'),
                    ),
                  );
                } else {
                  testName = testNameContext;
                }
              }

              if (testNameContext == 'nav') {
                final testNameExists =
                    await testNameCheckIfExists(testName, '${user.uid}');
                if (!testNameExists) {
                  // choose image from gallery
                  final imageFromGallery =
                      // ignore: deprecated_member_use
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  print('gallery image path: ${imageFromGallery.path}');

                  setState(() {
                    showProgress = true;
                  });

                  // initialize test image url
                  String testImageUrl;

                  // start firebase upload task
                  firebase_storage.UploadTask testImageUploadTask = _storage
                      .ref(
                          '${user.email}/tests/${basename(imageFromGallery.path)}')
                      .putFile(imageFromGallery);

                  setState(() {
                    progressMessage = "Uploading to server";
                  });

                  // push download url of uploaded image to testImageUrl string
                  try {
                    testImageUrl = await _storage
                        .ref(
                            '${user.email}/tests/${basename(imageFromGallery.path)}')
                        .getDownloadURL();
                    print('uploaded image: $testImageUrl');
                  } catch (e) {
                    firebase_storage.TaskSnapshot snapshot =
                        await testImageUploadTask;
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

                  String resultsEndpoint = await getOCRLink(imageBytes);
                  String ocrText = '';

                  Timer(Duration(seconds: 2), () async {
                    ocrText = await getTextFromOCR(resultsEndpoint);

                    print('ocr was completed.');

                    setState(() {
                      progressMessage = "Validating";
                    });

                    // push data to db and validate test result
                    validTest = await validateAndUploadData(
                        ocrText, user.uid, testName, testImageUrl);

                    print('gallery intent valid test result: $validTest');
                    setState(() {
                      // set the progress indicator to true so it would not be visible
                      showProgress = false;
                    });
                    // return response to user according to test result
                    if (!validTest) {
                      msgController.clear();
                      if (testNameContext == 'nav') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'The result uploaded is not authentic. You may be ineligible for travel.'),
                          ),
                        );
                      } else {
                        var snackBar = SnackBar(
                          content: Text(
                              'The result uploaded is not authentic. You may be ineligible for travel.'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    } else {
                      msgController.clear();
                      if (testNameContext == 'nav') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Valid test result uploaded. You\'re good to go!'),
                          ),
                        );
                      } else {
                        var snackBar = SnackBar(
                            content: Text(
                                'Valid test result uploaded. You\'re good to go!'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  });
                } else {
                  return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test name already exists.'),
                    ),
                  );
                }
              } else {
                // choose image from gallery
                final imageFromGallery =
                    // ignore: deprecated_member_use
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                print('gallery image path: ${imageFromGallery.path}');

                setState(() {
                  showProgress = true;
                });

                // initialize test image url
                String testImageUrl;

                // start firebase upload task
                firebase_storage.UploadTask testImageUploadTask = _storage
                    .ref(
                        '${user.email}/tests/${basename(imageFromGallery.path)}')
                    .putFile(imageFromGallery);

                setState(() {
                  progressMessage = "Uploading to server";
                });

                // push download url of uploaded image to testImageUrl string
                try {
                  testImageUrl = await _storage
                      .ref(
                          '${user.email}/tests/${basename(imageFromGallery.path)}')
                      .getDownloadURL();
                  print('uploaded image: $testImageUrl');
                } catch (e) {
                  firebase_storage.TaskSnapshot snapshot =
                      await testImageUploadTask;
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

                String resultsEndpoint = await getOCRLink(imageBytes);
                String ocrText = '';

                Timer(Duration(seconds: 2), () async {
                  ocrText = await getTextFromOCR(resultsEndpoint);

                  print('ocr was completed.');

                  setState(() {
                    progressMessage = "Validating";
                  });

                  // push data to db and validate test result
                  validTest = await validateAndUploadData(
                      ocrText, user.uid, testName, testImageUrl);

                  print('gallery intent valid test result: $validTest');
                  setState(() {
                    // set the progress indicator to true so it would not be visible
                    showProgress = false;
                  });
                  // return response to user according to test result
                  if (!validTest) {
                    msgController.clear();
                    if (testNameContext == 'nav') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'The result uploaded is not authentic. You may be ineligible for travel.'),
                        ),
                      );
                    } else {
                      var snackBar = SnackBar(
                          content: Text(
                              'The result uploaded is not authentic. You may be ineligible for travel.'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  } else {
                    msgController.clear();
                    if (testNameContext == 'nav') {
                      // ignore: deprecated_member_use
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Valid test result uploaded. You\'re good to go!')));
                    } else {
                      var snackBar = SnackBar(
                          content: Text(
                              'Valid test result uploaded. You\'re good to go!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                });
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

class TestNameTextFormField extends StatelessWidget {
  final TextEditingController messageController;
  final String hintText;
  final Function onChanged;
  final bool isEnabled;

  TestNameTextFormField(
      {@required this.messageController,
      @required this.hintText,
      this.onChanged,
      this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: messageController,
      decoration: InputDecoration(
        counter: Container(),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        hintStyle: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: Colors.grey[800]),
        hintText: hintText,
        fillColor: MyColors.offWhite,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0)),
      ),
      validator: (String testName) {
        return testName.isEmpty ? 'Name is required' : null;
      },
      onChanged: onChanged,
      enabled: isEnabled,
    );
  }
}
