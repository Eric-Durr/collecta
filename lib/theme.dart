import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightColorScheme.surfaceVariant,
        indicatorColor: lightColorScheme.onSurfaceVariant.withOpacity(0.4)),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

TextTheme textTheme() {
  return const TextTheme(
      bodyText1: TextStyle(color: kTextColor),
      bodyText2: TextStyle(color: kTextColor));
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    systemOverlayStyle:
        SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    titleTextStyle: TextStyle(
      color: Color(0xBABAAAAA),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  );
}

InputDecorationTheme inputDecorationTheme() {
  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: lightColorScheme.secondary),
    gapPadding: 10,
  );
  return InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      enabledBorder: outlineInputBorder,
      focusColor: Colors.blue,
      border: outlineInputBorder);
}
