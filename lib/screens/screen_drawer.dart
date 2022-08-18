import 'dart:async';
import 'dart:io';

import 'package:collecta/constants.dart';
import 'package:collecta/controller/area.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:collecta/screens/insights/inisghts_screen.dart';
import 'package:collecta/screens/insights/widgets/map.dart';
import 'package:collecta/screens/splash/splash_screen.dart';
import 'package:collecta/screens/team_profile/team_profile.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:collecta/size_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
            body: <Widget>[
              InsightsScreen(location: _currentPosition, zoneAreas: areas),
              TransectAreaScreen(
                zoneAreas: areas,
                isOnline: isOnline,
                currentPosition: _currentPosition,
                updatePositionCallback: updatePositionCallback,
              ),
              TeamProfileScreen(
                username: sharedPreferences.getString('username'),
                hasConnection: isOnline,
              ),
            ][currentPageIndex],
          );
  }

  checkConnectionStatus() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile) {
      print("Internet connection is from Mobile data");
    } else if (result == ConnectivityResult.wifi) {
      print("internet connection is from wifi");
    } else if (result == ConnectivityResult.ethernet) {
      print("internet connection is from wired cable");
    } else if (result == ConnectivityResult.bluetooth) {
      print("internet connection is from bluethooth threatening");
    } else if (result == ConnectivityResult.none) {
      print("No internet connection");
    }
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

  determinePosition() async {
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

  getAndParseAreas() async {
    await getZoneAreas(_currentPosition.latitude, _currentPosition.longitude,
            sharedPreferences.getString('projectId'))
        .then((value) => areas = value);
    print(areas.length.toString());
  }

  updatePositionCallback(newPosition) {
    setState(() {
      _currentPosition = newPosition;
    });
  }
}
