import 'package:flutter/material.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/widgets/verificationCard.dart';
import 'package:kyt/widgets/card.dart';

class Verification3 extends StatefulWidget {
  static String id = "verification3";
  @override
  _Verification3State createState() => _Verification3State();
}

class _Verification3State extends State<Verification3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkPrimary,
        title: Text(MyStrings.test3Label),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            VerificationCard(
              text: MyStrings.test3Label,
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
