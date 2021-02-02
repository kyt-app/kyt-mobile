import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/screens/home.dart';
import 'package:kyt/screens/settings.dart';
import 'package:kyt/screens/qrcode.dart';
import 'package:kyt/screens/reportABug.dart';
import 'package:kyt/screens/upload.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Navigation extends StatefulWidget {
  static String id = "navigation";

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int pageIndex = 0;
  int firstIconColorInt = 1;
  int secondIconColorInt = 0;
  int thirdIconColorInt = 0;
  int fourthIconColorInt = 0;
  List _currentPage = [Home(), QRCode(), Upload(), Settings(), ReportABug()];
  List _iconColors = [Colors.white54, Colors.white];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: MyColors.offWhite,
        body: Container(
          child: _currentPage[pageIndex],
        ),
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: CircularNotchedRectangle(),
          child: Container(
            height: MyDimens.double_60,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MyDimens.double_20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: _iconColors[firstIconColorInt],
                    ),
                    onPressed: () {
                      setState(() {
                        pageIndex = 0;
                        firstIconColorInt = 1;
                        secondIconColorInt = 0;
                        thirdIconColorInt = 0;
                        fourthIconColorInt = 0;
                      });
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.qr_code,
                          color: _iconColors[secondIconColorInt]),
                      onPressed: () {
                        setState(() {
                          pageIndex = 1;
                          firstIconColorInt = 0;
                          secondIconColorInt = 1;
                          thirdIconColorInt = 0;
                          fourthIconColorInt = 0;
                        });
                      },
                      padding: EdgeInsets.only(right: MyDimens.double_60)),
                  IconButton(
                      icon: Icon(Icons.settings,
                          color: _iconColors[thirdIconColorInt]),
                      onPressed: () {
                        setState(() {
                          pageIndex = 3;
                          firstIconColorInt = 0;
                          secondIconColorInt = 0;
                          thirdIconColorInt = 1;
                          fourthIconColorInt = 0;
                        });
                      },
                      padding: EdgeInsets.only(left: MyDimens.double_60)),
                  IconButton(
                    icon: Icon(Icons.report,
                        color: _iconColors[fourthIconColorInt]),
                    onPressed: () {
                      setState(() {
                        pageIndex = 4;
                        firstIconColorInt = 0;
                        secondIconColorInt = 0;
                        thirdIconColorInt = 0;
                        fourthIconColorInt = 1;
                      });
                    },
                  ),
                ],
              ),
            ),
            color: MyColors.darkPrimary,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              pageIndex = 2;
            });
          },
          backgroundColor: MyColors.darkPrimary,
          child: Icon(
            Icons.add,
            size: 35,
          ),
        ));
  }
}
