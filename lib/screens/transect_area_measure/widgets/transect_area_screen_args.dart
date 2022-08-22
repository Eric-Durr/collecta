import 'package:geolocator/geolocator.dart';

class TransectAreaScreenArguments {
  final Position currentPosition;
  final bool isOnline;

  TransectAreaScreenArguments(this.currentPosition, this.isOnline);
}
