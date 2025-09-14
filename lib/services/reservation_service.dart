import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/models/reservations/reservation_details.dart';
import 'package:parknjet_app/models/reservations/reservations.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReservationService {
  static ReservationController reservationController =
      Get.put(ReservationController());
  static Future<List<ReservationDataModel>> fetchReservations() async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      print('User ID from Reservation: $userId');
      var apiUrl = "$commonApiUrl/reservations/user/$userId";
      final uri = Uri.parse(apiUrl);
      String? token = await GetToken.getToken();

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);
        final results = json['data'] as List<dynamic>?;
        if (results == null) {
          throw Exception('No data found in the response');
        }

        final reservations = results.map((e) {
          return ReservationDataModel.fromJson(e as Map<String, dynamic>);
        }).toList();

        return reservations;
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      throw Exception('Error fetching reservations: $e');
    }
  }

  static Future<ReservationDetailsDataModel> fetchReservationDetails(
      String driverEmail, String dropOffDate, int reservationID) async {
    print(driverEmail);
    print(dropOffDate);
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      // var apiUrl = "$commonApiUrl/reservations/$userId/$reservationID";
      var apiUrl = "$commonApiUrl/reservation_finder";
      final uri = Uri.parse(apiUrl);
      String? token = await GetToken.getToken();

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.post(uri, headers: {
        // 'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer $token',
      }, body: {
        "driverEmail": driverEmail,
        "dropOffDate": dropOffDate,
        "reservationId": reservationID.toString()
      });

      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body);
        final result = json['data'];
        // print(result['reservation'].toString());

        if (result == null) {
          throw Exception('No data found in the response');
        }

        final reservationDetails = ReservationDetailsDataModel.fromJson(
            result as Map<String, dynamic>);

        return reservationDetails;
      } else {
        throw Exception(
            'Failed to load reservation details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reservation details: $e');
      throw Exception('Error fetching reservation details: $e');
    }
  }

  static Future<void> cancelReservation(
      String driverEmail, String dropOffDate, int reservationID) async {
    try {
      var commonApiUrl = getApiBaseUrl();
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? userId = sharedPreferences.getInt("userId");

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      var apiUrl =
          "$commonApiUrl/member/$userId/reservation/$reservationID/cancel";
      final uri = Uri.parse(apiUrl);
      String? token = await GetToken.getToken();

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "driverEmail": driverEmail,
        "dropOffDate": dropOffDate,
      });

      if (response.statusCode == 200) {
        Get.snackbar(
          "Done",
          "Your reservation is canceled!",
          colorText: Colors.green,
          backgroundColor: Colors.green[50],
          snackPosition: SnackPosition.BOTTOM,
        );
        reservationController.onInit();
      } else {
        Get.snackbar(
          "Error",
          "Canceling reservation!",
          colorText: Colors.red,
          backgroundColor: Colors.red[50],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Canceling reservation!",
        colorText: Colors.red,
        backgroundColor: Colors.red[50],
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error fetching reservation details: $e');
      throw Exception('Error fetching reservation details: $e');
    }
  }
}
