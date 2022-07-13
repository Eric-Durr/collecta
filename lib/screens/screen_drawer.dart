import 'package:collecta/screens/insights/inisghts_screen.dart';
import 'package:collecta/screens/insights/widgets/map.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScreenDrawer extends StatefulWidget {
  static String routeName = '/app';
  const ScreenDrawer({Key key}) : super(key: key);

  @override
  State<ScreenDrawer> createState() => _ScreenDrawerState();
}

class _ScreenDrawerState extends State<ScreenDrawer> {
  int currentPageIndex = 0;

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
        TransectAreaScreen(),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][currentPageIndex],
    );
  }
}
