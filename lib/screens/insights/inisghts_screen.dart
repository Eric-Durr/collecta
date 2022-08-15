import 'package:collecta/constants.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:flutter/material.dart';
import 'package:collecta/screens/insights/widgets/body.dart';
import 'package:collecta/size_config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InsightsScreen extends StatelessWidget {
  static String routeName = '/insights';

  InsightsScreen({Key? key, required this.location, required this.zoneAreas})
      : super(key: key);

  final Position location;
  final List<MeasureArea> zoneAreas;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Insights Screen'),
          automaticallyImplyLeading: false,
        ),
        body: AnimatedMapControllerPage(
          location: location,
          zoneAreas: zoneAreas,
        ));
  }
}
