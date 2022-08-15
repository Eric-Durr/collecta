import 'package:collecta/models/transect_point.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../constants.dart';
import '../../../db/transect_point_database.dart';
import '../../../size_config.dart';
import '../../../widgets/form_error.dart';
import '../../transect_point_measure/initial_form_screen.dart';
import 'measure_list.dart';

class Body extends StatefulWidget {
  const Body({Key? key, required this.currentPosition, this.isOnline = false})
      : super(key: key);

  final Position currentPosition;
  final bool isOnline;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // status handlers
  bool isBussy = false;
  bool locationFail = false;
  final List<String> errors = [];

  // Geolocation
  final Geolocator geolocator = Geolocator();
  late Position _currentPosition;

  // Tool variables
  List<TransectPoint> measures = [];

  @override
  void initState() {
    super.initState();

    infoSetup();

    // Mocked connection check
  }

  void infoSetup() async {
    setState(() {
      isBussy = true;
    });
    _currentPosition = widget.currentPosition;
    if (widget.isOnline) {
      // onlineDB if user is connected
    } else {
      await initLocalDB();
    }

    setState(() {
      isBussy = false;
    });
  }

  Future initLocalDB() async {
    measures = await TransectPointDatabase.instance.readAll();

    if (measures.isEmpty) {
      measures.insert(
          0,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: DateTime.now(),
              hits: 3,
              areaId: 0,
              teamId: 0));
      measures.insert(
          1,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: DateTime.now(),
              hits: 3,
              areaId: 0,
              teamId: 0));

      measures.insert(
          2,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: DateTime.now(),
              hits: 3,
              areaId: 0,
              teamId: 0));
      measures.insert(
          3,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: DateTime.now(),
              hits: 3,
              areaId: 0,
              teamId: 0));

      measures.insert(
          4,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: DateTime.now(),
              hits: 3,
              areaId: 0,
              teamId: 0));
    }
    measures[1] = measures[0].copy(species: '', mulch: true, hits: 1);
    measures[2] = measures[0].copy(species: '', soil: true, hits: 1);
    measures[3] = measures[0].copy(species: '', stone: true, hits: 1);
    measures[4] = measures[0].copy(species: '', rock: true, hits: 1);
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
      }).catchError((e) {
        setState(() {
          locationFail = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          dismissDirection: DismissDirection.down,
          duration: const Duration(seconds: 20),
          backgroundColor: lightColorScheme.errorContainer,
          content: Text(
            e.toString(),
            style: TextStyle(color: lightColorScheme.onErrorContainer),
          ),
        ));
      });
    } else {
      setState(() {
        locationFail = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: Column(children: [
            SizedBox(height: SizeConfig.screenHeight * 0.04),
            if (isBussy)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: lightColorScheme.primaryContainer,
                ),
              ),
            if (!isBussy)
              Card(
                elevation: 0,
                color: lightColorScheme.primaryContainer,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isBussy) CircularProgressIndicator(),
                        if (!isBussy && !locationFail)
                          Text(
                            'Latitude: ${_currentPosition.latitude.toStringAsPrecision(8)}, Longitude: ${_currentPosition.longitude.toStringAsPrecision(8)}',
                            style: TextStyle(
                                color: lightColorScheme.onPrimaryContainer,
                                fontSize: getProportionateScreenWidth(12),
                                fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'Retry location load',
                            style: TextStyle(
                                color: lightColorScheme.onPrimaryContainer,
                                fontSize: getProportionateScreenWidth(12),
                                fontWeight: FontWeight.bold),
                          ),
                        FormError(errors: errors),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                          child: OutlinedButton(
                            onPressed: () async {
                              await _determinePosition();
                            },
                            child: const Icon(
                              Icons.replay_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: getProportionateScreenHeight(24)),
            FloatingActionButton(
              backgroundColor: Colors.black,
              splashColor: Colors.white.withOpacity(0.5),
              tooltip: 'Add area measure in current location',
              child: const Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(
                    context, TransectFormInitialScreen.routeName,
                    arguments: measures);
              },
            ),
            SizedBox(height: getProportionateScreenHeight(5)),
            const Text('Add area measure'),
            SizedBox(height: getProportionateScreenHeight(40)),
            isBussy
                ? CircularProgressIndicator()
                : MeasureList(
                    measures: measures,
                  ),
          ]),
        ),
      ),
    );
  }
}
