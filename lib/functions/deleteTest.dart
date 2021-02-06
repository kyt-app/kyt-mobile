import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> deleteTest(String testName, String authToken) async {
  final http.Response response = await http.post(
    'https://kyt-api.azurewebsites.net/tests/deletetest',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(
        <String, String>{"authToken": authToken, "testName": testName}),
  );

  if (response.statusCode == 200) {
    print(response.body);
    return response.body;
  }

  return null;
}
