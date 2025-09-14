import 'package:flutter/material.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordService {
  static BuildContext? get context => null;

  //send new referral
  static Future<http.Response> forgetPassword(String email) async {
    var commonApiUrl = getApiBaseUrl();

    var apiUrl = "$commonApiUrl/user/forgot_password";
    final uri = Uri.parse(apiUrl);
    try {
      String? token = await GetToken.getToken();
      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "user_name": email,
      });
      return response;
    } catch (e) {
      print(e);
      throw Exception('Failed to send forget password email!');
    }
  }
}
