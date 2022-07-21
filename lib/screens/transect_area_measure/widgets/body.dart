import 'package:collecta/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import '../../../size_config.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final Geolocator geolocator = Geolocator();
  late Position _currentPosition;
  bool isBussy = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  _determinePosition() async {
    setState(() {
      isBussy = true;
    });
    Geolocator.getCurrentPosition(
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
      });
      print(e);
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
                          if (_currentPosition != null)
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
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
                onPressed: () {},
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              const Text('Add area measure'),
              SizedBox(height: getProportionateScreenHeight(40)),
              Row(
                children: <Widget>[
                  Text(
                    'TEAM MEASURE HISTORY',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getProportionateScreenWidth(15),
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(10)),
                    child: Container(
                      width: getProportionateScreenWidth(100),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '0/100',
                    style: TextStyle(
                        color: lightColorScheme.error,
                        fontSize: getProportionateScreenWidth(15),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
