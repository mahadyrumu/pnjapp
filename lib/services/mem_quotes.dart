import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parknjet_app/config/urls.dart';
import 'package:parknjet_app/controllers/quotes_controller.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static QuotesController quoteController = Get.put(QuotesController());
  final String apiUrl =
      'https://plg.parknjetseatac.com/b/v1/api/v1.0/quotes/availability';

  fetchQuotes(Map<String, dynamic> payload) async {
    quoteController.resetQuoteErrorMessage();
    String queryString = Uri(queryParameters: payload).query;
    var commonApiUrl = getApiBaseUrl();
    String? token = await GetToken.getToken();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    var apiUrl = "$commonApiUrl/quotes/availability?$queryString";
    final uri = Uri.parse(apiUrl);
    print(uri);
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    final body = json.decode(response.body);
    // print(json.decode(response.body));
    if (response.statusCode == 200) {
      final data = body['data'];
      return data;
      // return GetMemQuote.fromJson(json.decode(response.body));
    } else if (response.statusCode == 422) {
      quoteController.setQuoteErrorMessage(body['message']);
      throw Exception('Failed to load quotes');
    } else if (response.statusCode == 403) {
      quoteController.setQuoteErrorMessage(body['message']);
      throw Exception(body['message'].toString());
    } else {
      throw Exception('Failed to load quotes');
    }
  }
}
