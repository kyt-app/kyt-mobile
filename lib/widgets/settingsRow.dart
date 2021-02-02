import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kyt/global/myColors.dart';

class SettingsRow extends StatelessWidget {
  SettingsRow({@required this.label, @required this.icon, this.isUpload});

  final bool isUpload;
  final IconData icon;
  final String label;
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
    // Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //         'An unknown error occurred. We were unable to verify the test.')));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 38.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        child: RaisedButton(
            onPressed: isUpload == null
                ? () {}
                : !isUpload
                    ? () async {
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
                      }
                    : () async {
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // clears dialog box
                        final imageFromGallery = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        final imageBytes = imageFromGallery.readAsBytesSync();
                        String ocrText = await getTextFromOCR(imageBytes);
                        validTest =
                            await validateText(ocrText, user.email, testName);
                        print('gallery intent valid test result: $validTest');

                        !validTest
                            ? Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'We couldn\'t verify your test results. Please try again.')))
                            : Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Valid test result uploaded. You\'re good to go!')));
                      },
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            color: MyColors.offWhite,
            padding: EdgeInsets.all(6.0),
            child: ListTile(
              trailing: Icon(icon),
              title: Text(label,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: MyColors.darkPrimary,
                      fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }
}
