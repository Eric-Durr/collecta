import 'package:flutter/material.dart';
import 'size_config.dart';

import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6A5583),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFEEDBFF),
  onPrimaryContainer: Color(0xFF25123B),
  secondary: Color(0xFF635C68),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE9DFEE),
  onSecondaryContainer: Color(0xFF1F1A24),
  tertiary: Color(0xFF74575B),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD9DE),
  onTertiaryContainer: Color(0xFF2B1519),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF1D1B1D),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1D1B1D),
  surfaceVariant: Color(0xFFE7E0E7),
  onSurfaceVariant: Color(0xFF49454B),
  outline: Color(0xFF7A757B),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFF323032),
  onInverseSurface: Color(0xFFF5EFF2),
  inversePrimary: Color(0xFFD6BCF1),
  surfaceTint: Color(0xFF6A5583),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD6BCF1),
  onPrimary: Color(0xFF3B2752),
  primaryContainer: Color(0xFF523E6A),
  onPrimaryContainer: Color(0xFFEEDBFF),
  secondary: Color(0xFFCDC3D2),
  onSecondary: Color(0xFF342E39),
  secondaryContainer: Color(0xFF4B4450),
  onSecondaryContainer: Color(0xFFE9DFEE),
  tertiary: Color(0xFFE3BDC2),
  onTertiary: Color(0xFF422A2E),
  tertiaryContainer: Color(0xFF5B3F44),
  onTertiaryContainer: Color(0xFFFFD9DE),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFB4AB),
  background: Color(0xFF1D1B1D),
  onBackground: Color(0xFFE6E1E4),
  surface: Color(0xFF1D1B1D),
  onSurface: Color(0xFFE6E1E4),
  surfaceVariant: Color(0xFF49454B),
  onSurfaceVariant: Color(0xFFCBC5CB),
  outline: Color(0xFF948F95),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFFE6E1E4),
  onInverseSurface: Color(0xFF323032),
  inversePrimary: Color(0xFF6A5583),
  surfaceTint: Color(0xFFD6BCF1),
);

// - - - - -  Others - - - - - - -
const kTextColor = Color(0xFF757575);
// - - - - - - - - - - - - - - - -
//  - - - - - - - - - - - - - - - - - - - - - -

// Other constants  - - - - - - - - - - - - - - - - - - - -
const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  color: Colors.black,
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
);
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - Text constants

final RegExp emailValidatorRegExp =
    RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9.]+\.[a-zA-Z]+');
const String kEmailNullError = 'Please Enter an Email';
const String kInvalidEmailError = 'Please Enter a valid Email';
const String kUserNullError = 'Please Enter your User';
const String kInvalidUserError = 'Please Enter an existing user';
const String kPassNullError = 'Please Enter a password';
const String kShortPassError = 'Password is too short';
const String kMatchPassError = 'Passwords don\'t match';
const String kAuthFailed = 'Authentication failed, wrong user or password ';

// --- Auth0 variables ---
const AUTH0_DOMAIN = 'collecta-auth-v01.eu.auth0.com';
const AUTH0_CLIENT_ID = 'rnrOHIGHvKrLwNQT2j7i87ndvhdUmv2d';
const AUTH0_REDIRECT_URI = 'com.example.collecta://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';
const BUNDLE_IDENTIFIER = 'com.example.collecta';
const REFRESH_TOKEN_KEY = 'refresh_token';
// --- ---------------- ---