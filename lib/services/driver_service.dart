import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/controllers/drivercontroller.dart';
import 'package:parknjet_app/models/driver/driver.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverService {
  static BuildContext? get context => null;
  static DriverController driverController = Get.put(DriverController());

  //to get full driver list
  static Future<List<DriverDataModel>> fetchDrivers() async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      print('User ID from driver: $userId');
      var apiUrl = "$commonApiUrl/drivers/$userId";
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
        final drivers = results.map((e) {
          return DriverDataModel(
            fullName: e['full_name'] ?? '',
            email: e['email'] ?? '',
            phone: e['phone'] ?? '',
            id: e['id'] ?? '',
          );
        }).toList();
        return drivers;
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      throw Exception('Error fetching drivers');
    }
  }

  //Add new driver
  static Future<DriverDataModel> addDriver(
      String fullName, String email, String phone) async {
    driverController.setEmailErrorMessage('');
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/drivers/$userId";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "full_name": fullName,
        "email": email,
        "phone": phone
      });

      if (response.statusCode == 201) {
        // Successful request
        // Parse the response and return the newly added driver info
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data')) {
          final Map<String, dynamic> driverData = responseData['data'];
          return DriverDataModel.fromJson(driverData);
        } else {
          throw Exception('Driver data not found in API response');
        }
      } else if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        driverController.setEmailErrorMessage(body['message']['email'][0]);
        throw Exception('Failed to add driver: ${body['message']['plate'][0]}');
      } else {
        // Handle other status codes
        throw Exception('Failed to add driver: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to add driver');
    }
  }

  //Update driver info

  static Future<void> updateDriver(
      int id, String fullName, String email, String phone) async {
    driverController.setEmailErrorMessage('');
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/drivers/$userId/$id";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      final response = await http.put(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "full_name": fullName,
        "email": email,
        "phone": phone
      });
      if (response.statusCode == 200) {
// Handle successful update
      } else if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        driverController.setEmailErrorMessage(body['message']['email'][0]);
        throw Exception(
            'Failed to update driver: ${body['message']['plate'][0]}');
      } else {
        // Handle API error
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(
            content: Text('Failed to update driver info'),
          ),
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to update driver');
    }
  }

  //Delete driver

  static Future<void> deleteDriver(BuildContext context, int id) async {
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/drivers/$userId/$id";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      final response = await http.delete(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      throw Exception('Failed to delete driver');
    }
  }

  static Future<void> handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    fetchDrivers();
  }
}
