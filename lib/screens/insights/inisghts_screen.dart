import 'package:collecta/constants.dart';
import 'package:flutter/material.dart';
import 'package:collecta/screens/insights/widgets/body.dart';
import 'package:collecta/size_config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InsightsScreen extends StatelessWidget {
  static String routeName = '/insights';

  InsightsScreen({Key? key, required this.location}) : super(key: key);

  final Position location;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Insights Screen'),
          automaticallyImplyLeading: false,
        ),
        body: AnimatedMapControllerPage(location: location));
  }
}
