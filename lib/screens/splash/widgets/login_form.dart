import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postgres/postgres.dart';

import '../../../constants.dart';
import '../../../main.dart';
import '../../../size_config.dart';
import '../../../widgets/custom_suffix_icon.dart';
import '../../../widgets/deffault_button.dart';
import '../../../widgets/form_error.dart';
import '../../screen_drawer.dart';

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late String user;
  late String password;
  late bool isBussy = false;
  late bool isLoggedIn = false;
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

  initDatabaseConnection() async {
    await databaseConnection.open().then((value) {
      setState(() {
        isLoggedIn = true;
      });
      debugPrint("Database Connected!");
    }).catchError((err) {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isBussy)
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                getProportionateScreenHeight(30),
              ),
              child: CircularProgressIndicator(
                color: lightColorScheme.primaryContainer,
              ),
            ),
          buildUserField(),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildPasswordField(),
          SizedBox(height: getProportionateScreenHeight(10)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: 'Continue',
            onPressedFunction: () async {
              // When auth system is applied
              if (_formKey.currentState!.validate()) {
                // Go to complete profile page
                _formKey.currentState!.save();

                setState(() {
                  isBussy = true;
                });

                // Pass this values in environment variables on flutter launch
                databaseConnection = await PostgreSQLConnection(
                    '10.6.129.74', 5432, 'ECOSISTEMAS_ERIC',
                    queryTimeoutInSeconds: 3600,
                    timeoutInSeconds: 3600,
                    username: '$user',
                    password: '$password');
                await initDatabaseConnection();
                setState(() {
                  isBussy = false;
                });
                if (isLoggedIn) {
                  Navigator.pushNamed(context, ScreenDrawer.routeName);
                } else {
                  addError(error: kAuthFailed);
                }

                // Go to main screen
              }
            },
          )
        ],
      ),
    );
  }

  TextFormField buildUserField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      onSaved: (newValue) => user = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kUserNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kUserNullError);
          return '';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: 'User',
          helperText: 'Enter a team name',
          suffixIcon: CustomSuffixIcon(assetPath: 'assets/icons/User.svg')),
    );
  }

  TextFormField buildPasswordField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return '';
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return '';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: 'Password',
          helperText: 'Enter your password',
          suffixIcon: CustomSuffixIcon(assetPath: 'assets/icons/Lock.svg')),
    );
  }
}
