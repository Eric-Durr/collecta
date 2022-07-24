import 'package:collecta/screens/team_profile/widgets/body.dart';
import 'package:flutter/material.dart';
import 'package:collecta/size_config.dart';

class TransectFormInitialScreen extends StatelessWidget {
  static String routeName = '/transect-form-initial';

  const TransectFormInitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Initial Transect Form Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body());
  }
}
