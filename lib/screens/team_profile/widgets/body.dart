import 'package:collecta/screens/splash/splash_screen.dart';
import 'package:collecta/screens/team_profile/widgets/user_banner.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import '../../../constants.dart';
import '../../../main.dart';
import '../../../size_config.dart';
import '../../../widgets/deffault_button.dart';
import '../../screen_drawer.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  late bool isBussy = false;
  late bool isLoggedIn = true;
  late String errorMessage;
  final List<String> errors = [];

  void addError({required String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  closeDatabaseConnection() async {
    await databaseConnection.close().then((value) {
      setState(() {
        isLoggedIn = false;
      });
      debugPrint("Database closed!");
    }).catchError((err) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              userBanner(),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              DefaultButton(
                  text: 'Log out',
                  onPressedFunction: () async {
                    // When auth system is applied
                    // Go to complete profile page
                    await closeDatabaseConnection();
                    setState(() {
                      isBussy = false;
                    });
                    if (!isLoggedIn) {
                      Navigator.pushNamed(context, SplashScreen.routeName);
                    } else {
                      addError(error: kAuthFailed);
                    }
                    // Go to main screen
                  })
            ]),
          ),
        ),
      ),
    );
  }
}
