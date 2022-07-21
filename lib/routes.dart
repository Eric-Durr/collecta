import 'package:collecta/screens/insights/inisghts_screen.dart';
import 'package:collecta/screens/screen_drawer.dart';
import 'package:collecta/screens/team_profile/team_profile.dart';
import 'package:collecta/screens/transect_area_measure/transect_area_measure.dart';
import 'package:flutter/widgets.dart';
import 'package:collecta/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  ScreenDrawer.routeName: (context) => ScreenDrawer(),
  InsightsScreen.routeName: (context) => InsightsScreen(),
  TransectAreaScreen.routeName: (context) => TransectAreaScreen(),
  TeamProfileScreen.routeName: (context) => TeamProfileScreen(),
};
