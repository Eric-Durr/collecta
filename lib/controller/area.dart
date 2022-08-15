import 'dart:convert';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:http/http.dart' as http;

Future<List<MeasureArea>> getZoneAreas(
    double lat, lon, String? projectId) async {
  var jsonResponse = null;
  int zone = lonLatToUTMZone(lon, lat);
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/areas/in-zone?zone=28'));
  jsonResponse = await json.decode(response.body);

  if (jsonResponse['areas'] != null) {
    List<MeasureArea> areas = [];

    jsonResponse['areas'].forEach((area) {
      if (area['proyecto'].toString() == projectId)
        areas.add(MeasureArea.fromJSON(area));
    });
    return areas;
  } else {
    return [];
  }
}
