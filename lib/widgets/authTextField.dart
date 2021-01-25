import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';

class AuthTextField extends StatelessWidget {
  AuthTextField(
      {@required this.hint,
      @required this.password,
      this.inputType,
      this.onChanged,
      this.maxLength});

  final TextInputType inputType;
  final String hint;
  final bool password;
  final Function onChanged;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      onChanged: onChanged,
      keyboardType: inputType,
      obscureText: password,
      decoration: InputDecoration(
        counter: Container(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        hintStyle: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: Colors.grey[800]),
        hintText: hint,
        fillColor: Colors.white54,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyColors.darkGrey, width: 2.0),
        ),
      ),
    );
  }
}
