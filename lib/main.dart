import 'package:flutter/material.dart';
import 'package:collecta/routes.dart';
import 'package:collecta/screens/splash/splash_screen.dart';
import 'package:postgres/postgres.dart';

import 'theme.dart';

late PostgreSQLConnection databaseConnection;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme(),
      // home: SplashScreen(),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
