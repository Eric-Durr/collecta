import 'dart:async';
import 'dart:io';

import 'package:collecta/screens/insights/inisghts_screen.dart';
import 'package:collecta/screens/insights/widgets/map.dart';
import 'package:collecta/screens/team_profile/team_profile.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:collecta/services/network_conectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScreenDrawer extends StatefulWidget {
  static String routeName = '/app';
  const ScreenDrawer({Key? key}) : super(key: key);

  @override
  State<ScreenDrawer> createState() => _ScreenDrawerState();
}

class _ScreenDrawerState extends State<ScreenDrawer> {
  int currentPageIndex = 0;
  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    print(this.isOnline);
    InternetConnectionChecker().onStatusChange.listen((status) {
      final isOnline = status == InternetConnectionStatus.connected;
      setState(() => this.isOnline = isOnline);
      print(isOnline);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        InsightsScreen(),
        TransectAreaScreen(hasInternet: this.isOnline),
        TeamProfileScreen(),
      ][currentPageIndex],
    );
  }
}
