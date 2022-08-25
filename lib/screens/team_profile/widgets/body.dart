import 'dart:io';

import 'package:collecta/controller/team.dart';
import 'package:collecta/screens/splash/splash_screen.dart';
import 'package:collecta/screens/team_profile/widgets/user_banner.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../main.dart';
import '../../../size_config.dart';
import '../../../widgets/deffault_button.dart';
import '../../screen_drawer.dart';

class Body extends StatefulWidget {
  Body({Key? key, this.username, this.hasConnection = false}) : super(key: key);

  final String? username;
  late bool hasConnection;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  late bool isBussy = false;
  late bool isLoggedIn = true;
  late String errorMessage;
  late String membersString;
  final List<String> errors = [];
  late SharedPreferences sharedPreferences;

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

  @override
  void initState() {
    // TODO: implement initState
    instanceSharedPreferences();

    super.initState();
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
              Text(widget.hasConnection ? 'online' : 'offline'),
              userBanner(widget.username),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              Text(
                'MEMBERS:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenWidth(18)),
              ),
              if (!isBussy) Text(membersString),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              DefaultButton(
                  text: 'Log out',
                  onPressedFunction: () async {
                    // When auth system is applied
                    // Go to complete profile page
                    setState(() {
                      isBussy = false;
                    });
                    var sharedPreference =
                        await SharedPreferences.getInstance();
                    sharedPreference.clear();
                    sharedPreference.commit();

                    Navigator.pushNamed(context, SplashScreen.routeName);
                    // Go to main screen
                  })
            ]),
          ),
        ),
      ),
    );
  }

  instanceSharedPreferences() async {
    setState(() {
      isBussy = true;
    });
    sharedPreferences = await SharedPreferences.getInstance();
    membersString = await getTeamMembers(
        int.parse(await sharedPreferences.getString('teamId') ?? '-1'));

    setState(() {
      isBussy = false;
    });
  }
}
