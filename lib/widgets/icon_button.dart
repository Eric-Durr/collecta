import 'package:flutter/material.dart';

import '../constants.dart';
import '../size_config.dart';

class IconButton extends StatelessWidget {
  final Widget icon;

  const IconButton({
    Key key,
    this.icon,
    this.onPressedFunction,
  }) : super(key: key);

  final Function onPressedFunction;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressedFunction,
      child: icon,
    );
  }
}
