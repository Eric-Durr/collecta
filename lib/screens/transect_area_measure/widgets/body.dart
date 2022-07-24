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
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final Geolocator geolocator = Geolocator();
  late Position _currentPosition;
  bool isBussy = false;
  final List<String> errors = [];
  bool locationFail = false;

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  _determinePosition() async {
    setState(() {
      isBussy = true;
    });
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        isBussy = false;
        _currentPosition = position;
      });
    }).catchError((e) {
      setState(() {
        isBussy = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: SingleChildScrollView(
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
                              _currentPosition.toString(),
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
                  TransectPointDatabase.instance.create(TransectPoint(
                      species: 'Rumex Lunaria',
                      soil: false,
                      mulch: false,
                      rock: false,
                      stone: false,
                      annotations: '',
                      created: DateTime.now(),
                      mark: DateTime.now(),
                      hits: 3,
                      areaId: 150,
                      teamId: 5));
                  // Navigator.pushNamed(
                  //     context, TransectFormInitialScreen.routeName);
                },
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              const Text('Add area measure'),
              SizedBox(height: getProportionateScreenHeight(40)),
              MeasureList(),
            ]),
          ),
        ),
      ),
    );
  }
}
