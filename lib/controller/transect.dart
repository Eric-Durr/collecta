import 'dart:convert';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<TransectPoint>?> getTeamTransectMeasures(String teamId) async {
  var jsonResponse = null;
  var response =
      await http.get(Uri.parse('$API_SERVER:$API_PORT/api/transect/$teamId'));

  if (response.statusCode == 200) {
    jsonResponse = await json.decode(response.body);

    if (jsonResponse['measures'] != null) {
      List<TransectPoint> measures = [];

      jsonResponse['measures'].forEach((measure) {
        measures.add(TransectPoint.fromJSON(measure));
      });
      return measures;
    } else {
      return [];
    }
  } else {
    return [];
  }
}
