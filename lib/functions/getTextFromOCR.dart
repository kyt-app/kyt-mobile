import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getTextFromOCR(String endpoint, BuildContext context) async {
  String ocrText = '';

  final resultsResponse = await http.get(endpoint, headers: <String, String>{
    'Ocp-Apim-Subscription-Key': 'b583a5bb13ff448399982684386e48ac'
  });

  if (resultsResponse.statusCode == 200) {
    Map<String, dynamic> responseMap = json.decode(resultsResponse.body);

    if (responseMap['status'] == 'running') {
      print('it\'s taking longer than usual');
      Scaffold.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('It\'s taking longer than usual.')
      ));

      return getTextFromOCR(endpoint, context);

    } else {
      for (var region in responseMap['analyzeResult']['readResults']) {
        for (var lines in region['lines']) {
          for (var words in lines['words']) {
            ocrText += words['text'] + ' ';
          }
        }
      }

      DateTime dateTime = getDateFromText(ocrText);
      return [ocrText, dateTime];
    }
  }

  return null;
}

Map<String, int> monthsMap = {
  "Jan": 1,
  "Feb": 2,
  "Mar": 3,
  "Apr": 4,
  "May": 5,
  "Jun": 6,
  "Jul": 7,
  "Aug": 8,
  "Sep": 9,
  "Oct": 10,
  "Nov": 11,
  "Dec": 12,
  "January": 1,
  "February": 2,
  "March": 3,
  "April": 4,
  "June": 6,
  "July": 7,
  "August": 8,
  "September": 9,
  "October": 10,
  "November": 11,
  "December": 12
};

DateTime getDateFromText(String ocrText) {
  RegExp months = RegExp(r"(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)");
  RegExp altDate = RegExp(r"(\d{1,2}/\d{1,2}/\d{4})");
  String date;
  DateTime dateTime;

  if (ocrText.indexOf(months) < 0) {
    if (ocrText.indexOf(altDate) < 0) {
      // use current date if no date found
      dateTime = DateTime.now();
    } else {
      // match mm/dd/yyyy or dd/mm/yyyy
      date = ocrText.substring(ocrText.indexOf(altDate), ocrText.indexOf(altDate) + 10);
      List<String> dateList = date.split("/");
      dateTime = DateTime.utc(int.parse(dateList.last), int.parse(dateList[1]), int.parse(dateList[0]), 15, 00, 00);
    }
  } else {
    // get text around month name
    String rawDateArea = ocrText.substring(ocrText.indexOf(months) - 30, ocrText.indexOf(months)) + ocrText.substring(ocrText.indexOf(months), ocrText.indexOf(months) + 30);
    // strip string until year
    date = rawDateArea.substring(0, rawDateArea.indexOf(RegExp(r"\d{4}")) + 4);
    // strip string before day
    date = date.substring(date.indexOf(RegExp(r"\d{1,2}")));
    List<String> dateList = date.split(" ");
    // convert customized date string to datetime object
    dateTime = DateTime.utc(int.parse(dateList.last), monthsMap[dateList[1]], int.parse(dateList[0]), 15, 00, 00);
  }

  return dateTime;
}