import 'package:collecta/models/measure_area.dart';
import 'package:flutter/material.dart';
import 'package:collecta/screens/transect_area_measure/widgets/body.dart';
import 'package:collecta/size_config.dart';
import 'package:geolocator/geolocator.dart';

class TransectAreaScreen extends StatefulWidget {
  static String routeName = '/transect-area';

  TransectAreaScreen(
      {Key? key,
      required this.currentPosition,
      required this.zoneAreas,
      required this.updatePositionCallback,
      this.isOnline = false})
      : super(key: key);

  final bool isOnline;
  late Position currentPosition;
  final List<MeasureArea> zoneAreas;
  Function(Position) updatePositionCallback;

  @override
  State<TransectAreaScreen> createState() => _TransectAreaScreenState();
}

class _TransectAreaScreenState extends State<TransectAreaScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Transect Area Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body(
          currentPosition: widget.currentPosition,
          isOnline: widget.isOnline,
          zoneAreas: widget.zoneAreas,
          updatePositionCallback: updatePositionCallback,
        ));
  }

  updatePositionCallback(newPosition) {
    widget.updatePositionCallback(newPosition);
  }
}
