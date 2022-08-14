import 'dart:convert';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:http/http.dart' as http;

Future<List<MeasureArea>> getZoneAreas(double lat, lon) async {
  var jsonResponse = null;
  int zone = lonLatToUTMZone(lon, lat);
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/areas/in-zone?zone=28'));
  String jsonDataString = response.body.toString();
  jsonResponse = await jsonDecode(jsonDataString);

  if (jsonResponse['areas'] != null) {
    print(jsonResponse.toString());
    List<MeasureArea> areas = [];
    return jsonResponse['areas'].forEach((area) => print(area.toString()));
  } else {
    return [];
  }
}
