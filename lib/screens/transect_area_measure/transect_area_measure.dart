import 'package:flutter/material.dart';
import 'package:collecta/screens/transect_area_measure/widgets/body.dart';
import 'package:collecta/size_config.dart';
import 'package:geolocator/geolocator.dart';

class TransectAreaScreen extends StatelessWidget {
  static String routeName = '/transect-area';

  const TransectAreaScreen(
      {Key? key, required this.currentPosition, this.isOnline = false})
      : super(key: key);

  final bool isOnline;
  final Position currentPosition;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Transect Area Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body(
          currentPosition: currentPosition,
          isOnline: isOnline,
        ));
  }
}
