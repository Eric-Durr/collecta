import 'package:collecta/constants.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:collecta/screens/splash/widgets/teams_rank_list.dart';
import 'package:collecta/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AnimatedMapControllerPage extends StatefulWidget {
  static const String route = 'map_controller_animated';

  const AnimatedMapControllerPage(
      {Key? key, required this.location, required this.zoneAreas})
      : super(key: key);

  final Position location;
  final List<MeasureArea> zoneAreas;

  @override
  AnimatedMapControllerPageState createState() {
    return AnimatedMapControllerPageState();
  }
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {
  late MapController mapController;
  bool isBussy = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    markers.add(Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(
        widget.location.latitude,
        widget.location.longitude,
      ),
      builder: (ctx) => Container(
        key: const Key('blue'),
        child: Icon(
          MdiIcons.pin,
          color: Colors.red,
          size: getProportionateScreenWidth(25),
        ),
      ),
    ));
    widget.zoneAreas.forEach((area) {
      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(
          double.parse(area.lat),
          double.parse(area.lon),
        ),
        builder: (ctx) => Container(
          key: const Key('blue'),
          child: Column(
            children: [
              Icon(
                MdiIcons.circle,
                color: Colors.blue,
                size: getProportionateScreenWidth(15),
              ),
              Text(
                'Area: ${area.id}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ));
    });

    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.001),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  'TEAM NEAR AREAS',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getProportionateScreenWidth(14),
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(getProportionateScreenWidth(10),
                        0, getProportionateScreenWidth(10), 0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 3, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.005),
          Container(
            height: SizeConfig.screenHeight * 0.655,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                zoom: 17.5,
                maxZoom: 17.5,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayerOptions(markers: markers)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
