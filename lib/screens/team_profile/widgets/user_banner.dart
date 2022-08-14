import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../main.dart';
import '../../../size_config.dart';

Row userBanner(String? username) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(0, 0, getProportionateScreenWidth(20), 0),
            child: CircleAvatar(
              radius: getProportionateScreenWidth(40),
              backgroundColor: lightColorScheme.secondaryContainer,
              child: Text(
                username.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                    fontSize: getProportionateScreenWidth(22),
                    fontWeight: FontWeight.w600,
                    color: lightColorScheme.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username.toString(),
            style: TextStyle(
                fontSize: getProportionateScreenWidth(18),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.00001),
          Text(
            // To be replaced with database data
            'Universidad de La Laguna',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(14),
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(0)),
            child: Container(
              width: getProportionateScreenWidth(235),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 2, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
