import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

Future<String> getQRCodeLink(String email) async {
  final qrCodeEndpoint = Uri.parse('https://kyt-api.azurewebsites.net/qrcode?email=$email');
  final response = await http.get(qrCodeEndpoint);

  if (response.statusCode == 200) {
    return json.decode(response.body)['url'];
  }

  return null;
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Text('Settings page actually 😃')
        )
      ),
    );
  }
}
