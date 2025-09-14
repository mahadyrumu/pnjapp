import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/config/urls.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/controllers/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  static Future<void> authToken(
      String client, String provider, String accessToken) async {
    final ReservationController reservationController =
        Get.put(ReservationController());
    var commonApiUrl = getApiBaseUrl();
    var apiUrl = "$commonApiUrl/user/token";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'client': client,
          'provider': provider,
          'access_token': accessToken
        },
      );
      print('api o/p $response');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String token = responseData['token'];
        int userId = responseData['user_id'];

        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setString("token", token);
        await sharedPreferences.setInt("userId", userId);
        await reservationController.fetchReservations();

        final session = SessionController.instance;
        session.setSession(userId.toString(), token.toString(), '', '');

        print('Token verified successful!');
        print('Token: $token');
        print('User ID: $userId');
      } else {
        print('Sign-up failed with status code: ${response.statusCode}');
        print('Error message: ${response.body}');
        throw Exception('Failed to sign up');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to verify the token');
    }
  }
}
