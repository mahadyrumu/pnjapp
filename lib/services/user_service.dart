import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:parknjet_app/controllers/user_controller.dart';
import 'package:parknjet_app/models/user/user.dart';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/services/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static UserController userController = Get.put(UserController());
  static BuildContext? get context => null;
  final String apiUrl = " ";

  Future<http.Response> updateUser(
      String fullName, String email, String phone, String password) async {
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    String? token = await GetToken.getToken(); // Await the token
    var apiUrl = "$commonApiUrl/users/$userId";
    final uri = Uri.parse(apiUrl);
    print(uri);
    try {
      final response = await http.put(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          "full_name": fullName,
          "user_name": email,
          "phone": phone,
          "password": password
        },
      );

      return response;
    } catch (e) {
      print(e);
      throw Exception('Failed to update profile');
    }
  }

  Future<User?> getUserDetails() async {
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    String? token = await GetToken.getToken(); // Await the token
    var apiUrl = "$commonApiUrl/users/$userId";
    final uri = Uri.parse(apiUrl);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['data']);
      return User.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<http.Response> updatePassword(String currentPassword,
      String newPassword, String confirmPassword) async {
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    String? token = await GetToken.getToken(); // Await the token
    var apiUrl = "$commonApiUrl/users/$userId/password";
    final uri = Uri.parse(apiUrl);
    try {
      final response = await http.put(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      return response;
    } catch (e) {
      print(e);
      throw Exception('Failed to update password');
    }
  }
}
