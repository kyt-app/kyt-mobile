import 'package:http/http.dart' as http;

Future<String> getOCRLink(List<int> imageBytes) async {
  final ocrEndpoint = Uri.parse(
      'https://kyt-app-ocr.cognitiveservices.azure.com/vision/v3.2-preview.1/read/analyze');
  final readImageLink = await http.post(ocrEndpoint,
      headers: <String, String>{
        'Ocp-Apim-Subscription-Key': 'b583a5bb13ff448399982684386e48ac',
        'Content-Type': 'application/octet-stream'
      },
      body: imageBytes);

  String resultsEndpoint = '';

  if (readImageLink.statusCode == 202) {
    Map<String, String> link = readImageLink.headers;
    resultsEndpoint = link['operation-location'];
    print(resultsEndpoint);
  }

  return resultsEndpoint;
}
