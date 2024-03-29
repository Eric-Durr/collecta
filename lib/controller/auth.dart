import 'dart:convert';

import 'package:collecta/constants.dart';
import 'package:collecta/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

signIn(String username, password) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Map userData = {'username': username, 'password': password};

  var jsonResponse;

  var response = await http
      .post(Uri.parse('$API_SERVER:$API_PORT/api/auth/signin'), body: userData);

  if (response.statusCode == 200) {
    jsonResponse = json.decode(response.body);
    if (jsonResponse['accessToken'] != null) {
      await sharedPreferences.setString('token', jsonResponse['accessToken']);
      await sharedPreferences.setString('username', jsonResponse['username']);
      await sharedPreferences.setString(
          'teamId', jsonResponse['id'].toString());

      var teamResponse = await http.get(
          Uri.parse('$API_SERVER:$API_PORT/api/teams/${jsonResponse['id']}'));
      if (teamResponse.statusCode == 200) {
        var parsedTeamResponse = json.decode(teamResponse.body);
        await sharedPreferences.setString(
            'projectId', parsedTeamResponse['id_proyecto'].toString());
      } else {
        return 3;
      }

      return 0;
    } else {
      return 2;
    }
  } else if (response.statusCode == 400) {
    return 1;
  } else {
    return 4;
  }
}
