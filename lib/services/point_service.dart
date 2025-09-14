import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parknjet_app/models/point/point_data_model.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PointService {
  static BuildContext? get context => null;

  //to get full driver list
  static Future<PointDataModel> fetchPoints() async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      var apiUrl = "$commonApiUrl/points/$userId";
      final uri = Uri.parse(apiUrl);

      String? token = await GetToken.getToken(); // Await the token
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      final body = response.body;
      final json = jsonDecode(body);

      print(uri);
      print(json);

      if (response.statusCode == 200) {
        if (json is Map<String, dynamic> &&
            json['data'] is Map<String, dynamic>) {
          final pointData = PointDataModel.fromJson(json);

          return pointData;
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed to load points: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching points: $e');
      throw Exception('Error fetching points');
    }
  }
}
