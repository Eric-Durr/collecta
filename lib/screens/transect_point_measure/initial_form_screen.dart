import 'package:collecta/models/transect_point.dart';
import 'package:collecta/screens/team_profile/widgets/body.dart';
import 'package:collecta/screens/transect_point_measure/widgets/initial_body.dart';
import 'package:flutter/material.dart';
import 'package:collecta/size_config.dart';

class TransectFormInitialScreen extends StatelessWidget {
  static String routeName = '/transect-form-initial';

  const TransectFormInitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<TransectPoint> measures =
        ModalRoute.of(context)!.settings.arguments as List<TransectPoint>;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Initial Transect Form Screen'),
          automaticallyImplyLeading: true,
        ),
        body: InitialBody(
          measures: measures,
        ));
  }
}
