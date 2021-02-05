import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> testNameCheckIfExists(String testName, String authToken) async {
  final endpoint = Uri.parse(
      'https://kyt-api.azurewebsites.net/tests/checktestname?authToken=$authToken&testName=$testName');
  final response = await http.get(endpoint);

  if (response.statusCode == 200) {
    return json.decode(response.body)['boolean'];
  }

  return null;
}
