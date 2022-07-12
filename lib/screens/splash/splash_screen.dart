import 'package:flutter/material.dart';
import 'package:collecta/screens/splash/widgets/body.dart';
import 'package:collecta/size_config.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}
