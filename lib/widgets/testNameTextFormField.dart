import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class TestNameTextFormField extends StatelessWidget {
  final TextEditingController messageController;
  final String hintText;
  final Function onChanged;
  final bool isEnabled;

  TestNameTextFormField(
      {@required this.messageController,
      @required this.hintText,
      this.onChanged,
      this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: messageController,
      decoration: InputDecoration(
        counter: Container(),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        hintStyle: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: Colors.grey[800]),
        hintText: hintText,
        fillColor: MyColors.offWhite,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0)),
      ),
      validator: (String testName) {
        return testName.isEmpty ? 'Name is required' : null;
      },
      onChanged: onChanged,
      enabled: isEnabled,
    );
  }
}
