import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import '../../../widgets/custom_suffix_icon.dart';
import '../../../widgets/deffault_button.dart';
import '../../../widgets/form_error.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  String passwordVerify;
  final List<String> errors = [];

  void addError({String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildUserField(),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildPasswordField(),
          SizedBox(height: getProportionateScreenHeight(10)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: 'Continue',
            onPressedFunction: () {
              if (_formKey.currentState.validate()) {
                // Go to complete profile page
                _formKey.currentState.save();
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
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kUserNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidUserError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kUserNullError);
          return '';
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidUserError);
          return '';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: 'User',
          hintText: 'Team_01',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: CustomSuffixIcon(assetPath: 'assets/icons/User.svg')),
    );
  }

  TextFormField buildPasswordField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
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
          hintText: 'Enter your password',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: CustomSuffixIcon(assetPath: 'assets/icons/Lock.svg')),
    );
  }
}
