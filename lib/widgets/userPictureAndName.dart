import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/myDimens.dart';
import 'package:kyt/global/mySpaces.dart';

class UserPictureAndName extends StatelessWidget {
  UserPictureAndName({@required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              '${user.photoURL}',
              height: 100.0,
              width: 100.0,
            ),
          ),
          MySpaces.vGapInBetween,
          Text(
            '${user.displayName}',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: MyColors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
