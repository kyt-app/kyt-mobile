import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> validateAndUploadData(
    String text, String authToken, String testName, String testImageUrl, DateTime testDate) async {
  final String validationEndpoint = 'https://kyt-api.azurewebsites.net/verify';
  final validationResponse =
      await http.post(validationEndpoint, body: <String, String>{
    'authToken': authToken,
    'testName': testName,
    'timestamp': '$testDate',
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
