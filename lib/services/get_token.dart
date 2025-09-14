import 'package:shared_preferences/shared_preferences.dart';

class GetToken {
  static Future<String?> getToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    return token;
  }
}

class GetUserId {
  static Future<int?> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? userId =
        sharedPreferences.getInt("userId"); // Default value if userId is null

    return userId;
  }
}
