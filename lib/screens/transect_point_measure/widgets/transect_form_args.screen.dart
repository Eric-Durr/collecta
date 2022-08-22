import 'package:collecta/models/transect_point.dart';

class TransectArguments {
  final List<TransectPoint>? measures;
  final int? areaId;

  const TransectArguments({this.measures, this.areaId});
}
