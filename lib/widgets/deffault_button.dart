import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class DefaultButton extends StatelessWidget {
  static const defaultValue = Color(0xFFEEDBFF);
  static const defaultTextValue = Color(0xFF25123B);
  const DefaultButton({
    Key? key,
    required this.text,
    this.onPressedFunction,
    this.buttonColor = defaultValue,
    this.textColor = defaultTextValue,
  }) : super(key: key);

  final Color buttonColor;
  final Color textColor;
  final String text;
  final void Function()? onPressedFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
            foregroundColor: MaterialStateProperty.all<Color>(
                lightColorScheme.onPrimaryContainer),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                return Colors.white.withOpacity(0.30);
              },
            ),
          ),
          onPressed: onPressedFunction,
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: getProportionateScreenWidth(18),
                color: textColor),
          )),
    );
  }
}
