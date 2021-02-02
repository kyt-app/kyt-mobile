import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/screens/home.dart';
import 'package:kyt/screens/settings.dart';
import 'package:kyt/screens/upload.dart';

class Navigation extends StatefulWidget {
  static String id = "navigation";

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int pageIndex = 0;
  int firstIconColorInt = 1;
  int secondIconColorInt = 0;
  List _currentPage = [Home(), Upload(), Settings()];
  List _iconColors = [Colors.white54, Colors.white];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: MyDimens.double_60),
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
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: _iconColors[secondIconColorInt]),
                    onPressed: () {
                      setState(() {
                        pageIndex = 2;
                        firstIconColorInt = 0;
                        secondIconColorInt = 1;
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
              pageIndex = 1;
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
