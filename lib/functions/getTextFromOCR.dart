import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> getTextFromOCR(String endpoint, BuildContext context) async {
  String ocrText = '';

  final resultsResponse = await http.get(endpoint, headers: <String, String>{
    'Ocp-Apim-Subscription-Key': 'b583a5bb13ff448399982684386e48ac'
  });

  if (resultsResponse.statusCode == 200) {
    print(resultsResponse.body);
    Map<String, dynamic> responseMap = json.decode(resultsResponse.body);

    if (responseMap['status'] == 'running') {
      print('it\'s taking longer than usual');
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('It\'s taking longer than usual.')));

      return getTextFromOCR(endpoint, context);

    } else {
      for (var region in responseMap['analyzeResult']['readResults']) {
        for (var lines in region['lines']) {
          for (var words in lines['words']) {
            ocrText += words['text'] + ' ';
          }
        }
      }

      return ocrText;
    }
  }

  return null;
}
