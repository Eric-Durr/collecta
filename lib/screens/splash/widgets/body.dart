import 'package:collecta/constants.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';
import 'login_form.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;

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
              Image.asset('assets/images/logo.png'),
              SizedBox(height: getProportionateScreenHeight(40)),
              LoginForm(),
              SizedBox(height: getProportionateScreenHeight(40)),
              GestureDetector(
                onTap: () {}, // Go to account request page
                child: Text(
                  'Request Account',
                  style: TextStyle(
                      color: lightColorScheme.secondary,
                      fontSize: getProportionateScreenWidth(20),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
            ]),
          ),
        ),
      ),
    );
  }
}
