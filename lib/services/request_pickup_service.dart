import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/models/request_pickup/request_pickup.dart';
import 'package:parknjet_app/services/custom_response.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestPickupService {
  static BuildContext? get context => null;

  //Create new pickup request
  static Future<CustomResponse> createRequestPickup(
      int claimId, String phoneNumber, int minutes, String island) async {
    // print(claimId);
    // print(phoneNumber);
    // print(minutes);
    // print(island);
    var commonApiUrl = getApiBaseUrl();
    var apiUrl = "$commonApiUrl/pickup_request";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken(); // Await the token
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "claimId": claimId.toString(), // Convert int to String
            "minutes": minutes.toString(), // Convert int to String
            "island": island,
            "phone": phoneNumber,
          }));
      final body = response.body;
      final json = jsonDecode(body);

      if (response.statusCode == 401) {
        return CustomResponse(
          success: false,
          message: json['message'],
        );
      }

      if (response.statusCode == 404) {
        return CustomResponse(
          success: false,
          message: json['message'],
        );
      }

      if (response.statusCode == 200) {
        return CustomResponse(
          success: true,
          message: json['message'],
        );
      } else {
        return CustomResponse(
          success: false,
          message: "Failed to request pickup",
        );
      }
    } catch (e) {
      return CustomResponse(
        success: false,
        message: "Failed to request pickup",
      );
    }
  }

  static Future<List<RequestPickupDataModel>> fetchActivePickupRequest() async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      var apiUrl = "$commonApiUrl/pickup_request/$userId";
      final uri = Uri.parse(apiUrl);
      String? token = await GetToken.getToken(); // Await the token
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);
        final results = json['data'] as List<dynamic>;
        final activePickupRequest = results.map((e) {
          return RequestPickupDataModel.fromJson(e);
        }).toList();
        return activePickupRequest;
      } else {
        throw Exception(
            'Failed to load pickup request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pickup request: $e');
      throw Exception('Error pickup request');
    }
  }
}
