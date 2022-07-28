import 'package:flutter/material.dart';
import 'package:collecta/screens/transect_area_measure/widgets/body.dart';
import 'package:collecta/size_config.dart';

class TransectAreaScreen extends StatelessWidget {
  static String routeName = '/transect-area';

  const TransectAreaScreen({Key? key, this.hasInternet = false})
      : super(key: key);
  final bool hasInternet;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Transect Area Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body());
  }
}
