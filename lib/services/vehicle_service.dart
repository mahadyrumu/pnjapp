import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
import 'package:parknjet_app/models/vehicle/vehicles.dart';
import 'package:parknjet_app/services/custom_response.dart';
import 'package:parknjet_app/services/custom_response_with_data.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VehicleService {
  static BuildContext? get context => null;
  static VehicleController vehicleController = Get.put(VehicleController());
  //to get full driver list
  static Future<List<VehicleDataModel>> fetchVehicles() async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      print('User ID from vehicle: $userId');
      var apiUrl = "$commonApiUrl/vehicles/$userId";
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
        final vehicles = results.map((e) {
          return VehicleDataModel(
            makeModel: e['makeModel'] ?? '',
            plate: e['plate'] ?? '',
            vehicleLength: e['vehicleLength'] ?? '',
            id: e['id'] ?? '',
          );
        }).toList();
        return vehicles;
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      throw Exception('Error fetching vehicles');
    }
  }

  //Add new vehicle
  static Future<CustomResponseWithData> addVehicle(
      String makeModel, String plate, String vehicleLength) async {
    vehicleController.setPlateErrorMessage('');
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/vehicles/$userId";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      if (token == null) {
        throw Exception('Token is null'); // Handle null token case
      }
      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "makeModel": makeModel,
        "plate": plate,
        "vehicleLength": vehicleLength,
      });

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return CustomResponseWithData(
          success: true,
          message: "",
          data: data,
        );
      } else if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        return CustomResponseWithData(
          success: false,
          message: body['message']['plate'][0],
          data: body,
        );
      } else {
        throw Exception('Failed to add vehicle: ${response.body}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to add vehicle');
    }
  }
  //Update vehicle info

  static Future<CustomResponse> updateVehicle(
      int id, String makeModel, String plate, String vehicleLength) async {
    vehicleController.setPlateErrorMessage('');
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/vehicles/$userId/$id";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      final response = await http.put(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "makeModel": makeModel,
        "plate": plate,
        "vehicleLength": vehicleLength
      });
      if (response.statusCode == 200) {
        print('done');
        print('Make model $makeModel,plate $plate, length $vehicleLength');
        print('Make model $makeModel');
        return CustomResponse(
          success: true,
          message: "",
        );
        // Handle successful update, show a success message or perform other actions
      } else if (response.statusCode == 422) {
        final body = jsonDecode(response.body);
        return CustomResponse(
          success: false,
          message: body['message']['plate'][0],
        );
      } else {
        // Handle API error
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vehicle info'),
          ),
        );
        throw Exception('Failed to add vehicle');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to update vehicle');
    }
  }

  //Delete vehicle

  static Future<void> deleteVehicle(BuildContext context, int id) async {
    var commonApiUrl = getApiBaseUrl();

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/vehicles/$userId/$id";
    print(id);
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      print(token);
      final response = await http.delete(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      throw Exception('Failed to delete vehicle');
    }
  }

  static Future<void> handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    fetchVehicles();
  }
}
