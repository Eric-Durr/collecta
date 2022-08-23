import 'dart:convert';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// API requests
Future<List<MeasureArea>> getZoneAreas(
    double lat, lon, String? projectId) async {
  var jsonResponse = null;
  int zone = lonLatToUTMZone(lon, lat);
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/areas/in-zone?zone=$zone'))
      .catchError((e) {
    throw e;
  });
  jsonResponse = await json.decode(response.body);
  if (response.statusCode == 200) {
    if (jsonResponse['areas'] != null) {
      List<MeasureArea> areas = [];

      jsonResponse['areas'].forEach((area) {
        if (area['proyecto'].toString() == projectId) {
          areas.add(MeasureArea.fromJSON(area));
        }
      });
      return areas;
    } else {
      return [];
    }
  } else {
    print(response.body);
    return [];
  }
}

Future<MeasureArea?> getClosestArea(
    double lat, lon, List<MeasureArea> allAreas) async {
  var closestArea = allAreas.isEmpty ? null : allAreas[0];
  bool anyArea = false;
  allAreas.forEach((area) {
    // Filter areas for current location in 100 meters
    if (areaIsCloseTo(100, area, lat, lon)) {
      anyArea = true;
      // Get closest area to current location
      if (areaIsCloser(closestArea, area, lat, lon)) {
        closestArea = area;
      }
    }
  });

  return anyArea ? closestArea : null;
}

Future<MeasureArea?> getClosestAreaIn100m(
    double lat, lon, List<MeasureArea> allAreas) async {
  var closestArea = allAreas.isEmpty ? null : allAreas[0];
  bool anyArea = false;
  allAreas.forEach((area) {
    // Filter areas for current location in 100 meters
    if (areaIsCloseTo(0.1, area, lat, lon)) {
      anyArea = true;
      // Get closest area to current location
      if (areaIsCloser(closestArea, area, lat, lon)) {
        closestArea = area;
      }
    }
  });

  return anyArea ? closestArea : null;
}

Future<int> addArea(
  double lat,
  double lon,
  int id,
  String? projectId,
  String? annotations,
  List<MeasureArea> zoneAreas,
) async {
  MeasureArea newArea;
  int returnValue = 400;
  await getClosestArea(lat, lon, zoneAreas).then((area) async {
    print('i come frist');

    Map areaJSON = {};

    if (area != null) {
      areaJSON = {
        "id_area": id.toString(),
        "longitude": lon.toString(),
        "latitude": lat.toString(),
        "project_id": projectId,
        "annotations": annotations ?? '',
        "uTMZone": area.uTMZone,
        "geographicSystem":
            "+proj=utm +zone=${area.uTMZone.replaceAll(RegExp(r'[^0-9]'), '')} +datum=WGS84 +units=m +no_defs"
      };
    }

    var response = await http
        .post(Uri.parse('$API_SERVER:$API_PORT/api/areas/'), body: areaJSON);

    if (response.statusCode == 201) {
      var jsonResponse = await json.decode(response.body);
      MeasureArea newArea = MeasureArea.fromJSON(jsonResponse['area']);
      returnValue = 201;
    }
  });
  print('iam the last');
  return returnValue;
}

// Secondary methods
bool areaIsCloser(
    MeasureArea? closestArea, MeasureArea area, double lat, double lon) {
  if (2 *
          Geolocator.distanceBetween(
            double.parse(closestArea!.lat),
            double.parse(closestArea.lon),
            lat,
            lon,
          ) /
          2 >
      2 *
          Geolocator.distanceBetween(
            double.parse(area.lat),
            double.parse(area.lon),
            lat,
            lon,
          ) /
          2) {
    return true;
  }
  return false;
}

bool areaIsCloseTo(double meters, MeasureArea area, double lat, lon) {
  if (double.parse(area.lat) > latMinusOffset(lat, meters) &&
      double.parse(area.lon) > lonMinusOffset(lat, lon, meters) &&
      double.parse(area.lat) < latPlusOffset(lat, meters) &&
      double.parse(area.lon) < lonPlusOffset(lat, lon, meters)) {
    return true;
  }
  return false;
}

// Earth radius
const double R = 6378;
// Offset tolerance in Km
const double EPS = 0.1;

double latPlusOffset(double lat, double meters) {
  return (lat + (meters / R) * (180 / pi));
}

double latMinusOffset(double lat, double meters) {
  return (lat - (meters / R) * (180 / pi));
}

double lonPlusOffset(double lat, double lon, double meters) {
  return (lon + (meters / R) * (180 / pi) / cos(pi * lat / 180));
}

double lonMinusOffset(double lat, double lon, double meters) {
  return (lon - (meters / R) * (180 / pi) / cos(pi * lat / 180));
}
