import 'package:flutter/material.dart';
import 'package:collecta/screens/transect_area_measure/widgets/body.dart';
import 'package:collecta/size_config.dart';

class TransectAreaScreen extends StatelessWidget {
  static String routeName = '/transect-area';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Transec Area Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body());
  }
}
