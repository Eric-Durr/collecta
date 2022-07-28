import 'package:collecta/size_config.dart';
import 'package:flutter/material.dart';

class ProgressHeader extends StatelessWidget {
  final String stepTitle;
  const ProgressHeader({
    Key? key,
    required this.stepTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: SizeConfig.screenWidth * 0.5,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Text(
                  stepTitle,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getProportionateScreenWidth(14),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: SizeConfig.screenWidth * 0.38,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 2, color: Colors.black),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
