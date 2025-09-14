import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/config/urls.dart';
import 'package:parknjet_app/models/prepaid_packages/prepaid_package.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrepaidPackageService {
  final String apiUrl = 'https://plg.parknjetseatac.com/b/api/prepaid_packages';

  Future<List<PrepaidPackage>> fetchPrepaidPackages() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> packagesJson = data['data'];
      return packagesJson.map((json) => PrepaidPackage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load prepaid packages');
    }
  }

  static Future<Map<String, dynamic>> fetchPrepaidPackageDays() async {
    var commonApiUrl = getApiBaseUrl();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    String? token = await GetToken.getToken(); // Await the token
    var apiUrl = "$commonApiUrl/prepaid_days/$userId";

    try {
      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception('Failed to fetch data');
        }
      } else {
        throw Exception('Failed to load prepaid package days');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
