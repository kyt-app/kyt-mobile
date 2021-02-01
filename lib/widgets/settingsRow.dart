import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class SettingsRow extends StatelessWidget {
  SettingsRow({@required this.label, @required this.icon});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 38.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        child: RaisedButton(
            onPressed: () {},
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            color: MyColors.offWhite,
            padding: EdgeInsets.all(6.0),
            child: ListTile(
              trailing: Icon(icon),
              title: Text(label,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: MyColors.darkPrimary,
                      fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }
}
