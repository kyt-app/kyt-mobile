import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class About extends StatefulWidget {
  static String id = "about";

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: MyColors.darkPrimary,
          centerTitle: true,
          title: Text('About',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: MyColors.white)),
        ),
        body: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: MyDimens.double_20, vertical: MyDimens.double_20),
            child: Column(
              children: [
                Image.network(
                  'https://cdn.discordapp.com/attachments/720733621811544165/806287045315919923/77614464-removebg-preview.png',
                  height: 150.0,
                  width: 150.0,
                ),
                Text(
                  '\nKYT is a privacy-focused and entrusted intermediary service between travellers and travel service providers, which enables passengers to share the required health records without revealing any other personal information. ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: MyColors.black,
                  ),
                ),
                Text(
                  '\nKYT acts as a middleman and creates a digital health pass for a passenger centered around COVID-19 tests/vaccine reports. \n\nAll of the KYT users have their underlying data secure and authenticated using their passport numbers.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: MyColors.black,
                  ),
                ),
                Text(
                  '\nAs a travel service provider, a person can view and validate a passenger’s test history as per the requirements by simply scanning a QR Code! \n\nKYT, thus, provides a reinvented contact-less approach to travel, expedits the anticipated procedural delays, and makes travel seamless and hassle-free for all the stakeholders.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: MyColors.black,
                  ),
                )
              ],
            )));
  }
}
