import 'dart:convert';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// API requests
Future<String> getTeamMembers(int id) async {
  var jsonResponse = null;

  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/teams/$id/members'))
      .catchError((e) {
    throw e;
  });
  jsonResponse = await json.decode(response.body);
  if (response.statusCode == 200) {
    if (jsonResponse['team_info'] != null) {
      List<String> members = [];

      jsonResponse['team_info'].forEach((member) {
        members.add(
            '\n${member['nombre']} ${member['institucion']} ${member['rol']}\n');
      });
      return members.join('\n');
    } else {
      return '';
    }
  } else {
    print(response.body);
    return '';
  }
}
