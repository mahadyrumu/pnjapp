import 'package:flutter/material.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/config/urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReferralService {
  static BuildContext? get context => null;

  //send new referral
  static Future<http.Response> sendReferralInvitation(String email) async {
    print(email.toString());
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/referrals/$userId";
    final uri = Uri.parse(apiUrl);
    print(uri);
    try {
      String? token = await GetToken.getToken();
      final response = await http.post(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "email": email,
      });

      return response;
    } catch (e) {
      print(e);
      throw Exception('Failed to send invitation');
    }
  }
}
