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
              child: Container(
                child: Text(
                  username.toString().split('_')[0].substring(0, 2) +
                      username.toString().split('_')[1],
                  style: TextStyle(
                      fontSize: getProportionateScreenWidth(26),
                      fontWeight: FontWeight.w900,
                      color: lightColorScheme.onSecondaryContainer),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username.toString().split('_').join(' '),
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
