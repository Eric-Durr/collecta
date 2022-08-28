import 'dart:async';

import 'package:collecta/constants.dart';
import 'package:collecta/controller/area.dart';
import 'package:collecta/controller/species.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:collecta/screens/insights/inisghts_screen.dart';
import 'package:collecta/screens/splash/splash_screen.dart';
import 'package:collecta/screens/team_profile/team_profile.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:collecta/size_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenDrawer extends StatefulWidget {
  static String routeName = '/app';
  const ScreenDrawer({Key? key}) : super(key: key);

  @override
  State<ScreenDrawer> createState() => _ScreenDrawerState();
}

class _ScreenDrawerState extends State<ScreenDrawer> {
  late SharedPreferences sharedPreferences;

  // Status handlers
  bool isBussy = false;
  bool isOnline = false;
  bool locationFail = false;
  final List<String> errors = [];

  // Drawer variables
  int currentPageIndex = 0;
  late String currentInitState = '';

  // Connectivity
  StreamSubscription? connection;

  // Geolocation
  final Geolocator geolocator = Geolocator();
  late Position _currentPosition;
  late List<MeasureArea> areas = [];
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  @override
  void initState() {
    statusSetup();
    // Connectivity subscription
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isOnline = false;
        });
      } else if (result == ConnectivityResult.mobile) {
        //connection is mobile data network
        setState(() {
          isOnline = true;
        });
      } else if (result == ConnectivityResult.wifi) {
        //connection is from wifi
        setState(() {
          isOnline = true;
        });
      }
    });

    super.initState();
  }

  void statusSetup() async {
    setState(() {
      isBussy = true;
    });

    // Login process
    setState(() {
      currentInitState = 'Checking logging status';
    });
    await checkLoginStatus();

    // Connectivity process
    setState(() {
      currentInitState = 'Checking connection status';
    });
    await checkConnectionStatus();

    // Location process
    setState(() {
      currentInitState = 'Searching user location';
    });

    await determinePosition();

    // Zone area retrieving process
    setState(() {
      currentInitState = 'Retrieving area data';
    });

    await getAndParseAreas();

    // Zone area retrieving process
    setState(() {
      currentInitState = 'Retrieving species';
    });

    await getSpecies();

    setState(() {
      isBussy = false;
    });
  }

  @override
  void dispose() {
    connection!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isBussy
        ? Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                    Image.asset(
                      'assets/images/logo.png',
                      width: SizeConfig.screenWidth * 0.3,
                    ),
                    SizedBox(height: getProportionateScreenHeight(40)),
                    Text(currentInitState),
                    SizedBox(height: getProportionateScreenHeight(40)),
                    const CircularProgressIndicator()
                  ],
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'connection status: ${isOnline ? 'online' : 'offline'}',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: getProportionateScreenHeight(16)),
              ),
              backgroundColor: isOnline
                  ? successContainer.withAlpha(150)
                  : lightColorScheme.tertiaryContainer,
              toolbarHeight: getProportionateScreenHeight(35),
              automaticallyImplyLeading: false,
            ),
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(MdiIcons.chartBoxOutline),
                  selectedIcon: Icon(MdiIcons.chartBox),
                  label: 'Insights',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.pin_drop),
                  icon: Icon(Icons.pin_drop_outlined),
                  label: 'Transect',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.person),
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: <Widget>[
                InsightsScreen(location: _currentPosition, zoneAreas: areas),
                TransectAreaScreen(
                  zoneAreas: areas,
                  isOnline: isOnline,
                  currentPosition: _currentPosition,
                  updatePositionCallback: updatePositionCallback,
                  updateAreasCallback: updateAreasCallback,
                ),
                TeamProfileScreen(
                  username: sharedPreferences.getString('username'),
                  hasConnection: isOnline,
                ),
              ][currentPageIndex],
            ),
          );
  }

  checkConnectionStatus() async {
    var result = await Connectivity().checkConnectivity();

    setState(() {
      isOnline = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    });
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.pushNamed(context, SplashScreen.routeName);
    }
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  determinePosition() async {
    LocationPermission permission;
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    setState(() {
      setState(() {
        locationFail = true;
      });
      _currentPosition = position;
    });
  }

  getAndParseAreas() async {
    await getZoneAreas(_currentPosition.latitude, _currentPosition.longitude,
            sharedPreferences.getString('projectId'))
        .then((value) => areas = value)
        .catchError((e) {
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

  getSpecies() async {
    List<String> allSpecies = await getTransectSpeciesNamesNoQuery();
    await sharedPreferences.setStringList(
        'completeTransectSpeciesList', allSpecies);
  }

  updatePositionCallback(newPosition) {
    setState(() {
      _currentPosition = newPosition;
    });
  }

  updateAreasCallback(newAreaList) {
    setState(() {
      areas = newAreaList;
    });
  }
}
