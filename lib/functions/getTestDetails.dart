import 'package:http/http.dart' as http;

Future<String> getTestDetails(String testName, String authToken) async {
  final testDetailsEndpoint = Uri.parse(
      'https://kyt-api.azurewebsites.net/tests/testdetails?authToken=$authToken&testName=$testName');
  final response = await http.get(testDetailsEndpoint);

  if (response.statusCode == 200) {
    return response.body;
  }

  return null;
}
