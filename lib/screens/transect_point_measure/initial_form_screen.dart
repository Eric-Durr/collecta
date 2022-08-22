import 'dart:ffi';

import 'package:collecta/screens/screen_drawer.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:collecta/screens/transect_point_measure/widgets/transect_form_args.screen.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:collecta/screens/team_profile/widgets/body.dart';
import 'package:collecta/screens/transect_point_measure/widgets/initial_body.dart';
import 'package:flutter/material.dart';
import 'package:collecta/size_config.dart';

class TransectFormInitialScreen extends StatefulWidget {
  static String routeName = '/transect-form-initial';

  const TransectFormInitialScreen({Key? key}) : super(key: key);

  @override
  State<TransectFormInitialScreen> createState() =>
      _TransectFormInitialScreenState();
}

class _TransectFormInitialScreenState extends State<TransectFormInitialScreen> {
  late List<TransectPoint> measures;
  bool hasNewMeasures = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    TransectArguments args =
        ModalRoute.of(context)!.settings.arguments as TransectArguments;
    setState(() {
      measures = args.measures!;
    });
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: getProportionateScreenWidth(35),
            ),
            onPressed: () {
              Navigator.pop(context, measures);
            },
          ),
          title: const Text('Initial Transect Form Screen'),
          automaticallyImplyLeading: true,
        ),
        body: InitialBody(
            measures: measures,
            areaId: args.areaId!,
            updateMeasuresCallback: updateMeasuresCallback));
  }

  updateMeasuresCallback(List<TransectPoint> newMeasures) {
    setState(() {
      measures = newMeasures;
    });
  }
}
