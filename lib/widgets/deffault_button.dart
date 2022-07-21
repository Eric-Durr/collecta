import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    required this.text,
    this.onPressedFunction,
  }) : super(key: key);

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
            backgroundColor: MaterialStateProperty.all<Color>(
                lightColorScheme.primaryContainer),
            foregroundColor: MaterialStateProperty.all<Color>(
                lightColorScheme.onPrimaryContainer),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.focused) ||
                    states.contains(MaterialState.pressed)) {
                  return lightColorScheme.onPrimary.withOpacity(0.35);
                }
                return Colors.white; // Defer to the widget's default.
              },
            ),
          ),
          onPressed: onPressedFunction,
          child: Text(
            text,
            style: TextStyle(fontSize: getProportionateScreenWidth(18)),
          )),
    );
  }
}
