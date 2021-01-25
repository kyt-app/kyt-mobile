import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/widgets/verificationCard.dart';
import 'package:kyt/widgets/card.dart';

class Verification1 extends StatefulWidget {
  static String id = "verification1";
  @override
  _Verification1State createState() => _Verification1State();
}

class _Verification1State extends State<Verification1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkPrimary,
        title: Text(MyStrings.test1Label),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            VerificationCard(
              text: MyStrings.test1Label,
              iconBool: true,
            ),
            MySpaces.vMediumGapInBetween,
            Text(
              'Hospital',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: MyColors.darkPrimary),
            ),
            MySpaces.vGapInBetween,
            VerifyCard(
              text: 'Fortis Hospital, Gurgaon',
            ),
            MySpaces.vMediumGapInBetween,
            Text(
              'Date',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: MyColors.darkPrimary),
            ),
            MySpaces.vGapInBetween,
            VerifyCard(
              text: '11th August, 2020',
            ),
          ],
        ),
      ),
    );
  }
}
