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

Future<List<TransectPoint>?> getTeamTransectMeasures(
    String areaId, String teamId) async {
  var jsonResponse = null;
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/transect/areas/$areaId'));

  if (response.statusCode == 200) {
    jsonResponse = await json.decode(response.body);

    if (jsonResponse['transectSpecies'] != null) {
      List<TransectPoint> measures = [];

      jsonResponse['transectSpecies'].forEach((measure) {
        Map<String, Object?> transectPointObj = {
          '_id': measure['punto'],
          'species': measure['species'],
          'soil': measure['species'] == 'Suelo',
          'mulch': measure['species'] == 'Mantillo',
          'rock': measure['species'] == 'Roca',
          'stone': measure['species'] == 'Piedra',
          'annotations': measure['observaciones'],
          'created_date': measure['fecha'],
          'mark_time': measure['marca'],
          'hits': measure['contactos'],
          'area_id': int.parse(areaId),
          'team_id': int.parse(teamId)
        };
        measures.add(TransectPoint.fromJSON(transectPointObj));
      });
      return measures;
    } else {
      return [];
    }
  } else {
    return [];
  }
}
