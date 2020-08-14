import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:kyt/widgets/verificationCard.dart';
import 'package:kyt/widgets/card.dart';

class Verification2 extends StatefulWidget {
  static String id = "verification2";
  @override
  _Verification2State createState() => _Verification2State();
}

class _Verification2State extends State<Verification2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkPrimary,
        title: Text(MyStrings.test2Label),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            VerificationCard(
              text: MyStrings.test2Label,
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
