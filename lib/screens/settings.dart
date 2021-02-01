import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/settingsRow.dart';

Future<String> getQRCodeLink(String email) async {
  final qrCodeEndpoint =
      Uri.parse('https://kyt-api.azurewebsites.net/qrcode?email=$email');
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              color: MyColors.darkPrimary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.all(MyDimens.double_40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MyDimens.double_200),
                    child: Image.network(
                      'https://github.com/rchtgpt.png',
                      height: 100.0,
                      width: 100.0,
                    ),
                  ),
                  MySpaces.vGapInBetween,
                  Text(
                    'Rachit Gupta',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: MyColors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          MySpaces.vGapInBetween,
          SettingsRow(
            icon: Icons.privacy_tip,
            label: 'Privacy and safety',
          ),
          SettingsRow(
            icon: Icons.privacy_tip,
            label: 'Privacy and safety',
          ),
          SettingsRow(
            icon: Icons.privacy_tip,
            label: 'Privacy and safety',
          ),
          SettingsRow(
            icon: Icons.privacy_tip,
            label: 'Privacy and safety',
          ),
        ],
      ),
    );
  }
}

class vSeparator extends StatelessWidget {
  const vSeparator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: MediaQuery.of(context).size.width,
      child: const DecoratedBox(
        decoration: const BoxDecoration(color: MyColors.darkPrimary),
      ),
    );
  }
}
