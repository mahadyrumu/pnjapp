import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/config/urls.dart';
import 'package:parknjet_app/services/custom_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<CustomResponse> signUp(String email, String password) async {
    var commonUrl = getApiBaseUrl();
    var apiUrl = "$commonUrl/user/signin";
    // const String apiUrl = 'http://localhost:9000/b/v1/api/v1.0/user/signin';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'client': "mobile", 'email': email, 'password': password},
      );
      final body = response.body;
      final json = jsonDecode(body);
      print(response.statusCode);
      print(json);
      if (response.statusCode == 200) {
        print('Sign-in successful!');

        String token = json['token'];
        print(json);
        var userId = json['user_id'];

        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setString("token", token);
        await sharedPreferences.setInt("userId", userId);
        // You can return data or status here if needed
        return CustomResponse(
          success: true,
          message: "",
        );
      } else if (response.statusCode == 422) {
        return CustomResponse(
          success: false,
          message: json['message']['email'][0],
        );
      } else {
        print('Sign-up failed with status code: ${response.statusCode}');
        print('Error message: ${response.body}');
        return CustomResponse(
          success: false,
          message: json['message'],
        );
      }
    } catch (error) {
      return CustomResponse(
        success: false,
        message: 'Failed to sign in',
      );
    }
  }
}
