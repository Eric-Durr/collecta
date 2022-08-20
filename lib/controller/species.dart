import 'dart:convert';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/helpers/utm_zone_convert.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getTransectSpeciesNames(String query) async {
  var jsonResponse = null;
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/species/transect/names'));

  if (response.statusCode == 200) {
    jsonResponse = await json.decode(response.body);

    List<String> species = [];

    jsonResponse['transectSpecies'].forEach((name) {
      species.add(name);
    });

    return species.where((species) {
      final String speciesToLower = species.toLowerCase();
      final String queryToLower = query.toLowerCase();
      print(queryToLower);
      print(speciesToLower);
      return speciesToLower.contains(queryToLower);
    }).toList();
  } else {
    throw Exception();
  }
}

Future<List<String>> getTransectSpeciesNamesLoaded(String query) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<String> filtered;

  filtered = sharedPreferences
      .getStringList('completeTransectSpeciesList')!
      .where((species) {
    final String speciesToLower = species.toLowerCase();
    final String queryToLower = query.toLowerCase();

    return speciesToLower.startsWith(queryToLower);
  }).toList();

  return filtered;
}

Future<List<String>> getTransectSpeciesNamesNoQuery() async {
  var jsonResponse = null;
  var response = await http
      .get(Uri.parse('$API_SERVER:$API_PORT/api/species/transect/names'));

  if (response.statusCode == 200) {
    jsonResponse = await json.decode(response.body);

    List<String> species = [];

    jsonResponse['transectSpecies'].forEach((name) {
      species.add(name);
    });

    return species.toList();
  } else {
    throw Exception();
  }
}
