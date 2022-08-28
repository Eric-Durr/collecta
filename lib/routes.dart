import 'package:collecta/screens/screen_drawer.dart';
import 'package:collecta/screens/transect_point_measure/initial_form_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:collecta/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  ScreenDrawer.routeName: (context) => ScreenDrawer(),
  TransectFormInitialScreen.routeName: ((context) =>
      TransectFormInitialScreen())
};
