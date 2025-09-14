import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionController {
  SessionController._internal();

  static final SessionController _instance = SessionController._internal();
  static SessionController get instance => _instance;

  String? userId;
  String? token;
  String? username;
  String? password;

  void setSession(
      String userId, String token, String username, String password) async {
    this.userId = userId;
    this.token = token;
    this.username = username;
    this.password = password;

    const storage = FlutterSecureStorage();
    await storage.write(key: "userId", value: userId);
    await storage.write(key: "token", value: token);
    await storage.write(
        key: "username", value: username == '' ? null : username);
    await storage.write(
        key: "password", value: password == '' ? null : password);
  }

  Future<void> loadSession() async {
    const storage = FlutterSecureStorage();
    final response = await Future.wait([
      storage.read(key: 'userId'),
      storage.read(key: 'token'),
      storage.read(key: 'username'),
      storage.read(key: 'password'),
    ]);

    userId = response[0];
    token = response[1];
    username = response[2];
    password = response[3];
  }

  void clearSession() async {
    userId = null;
    token = null;
    username = null;
    password = null;

    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: 'userId'),
      storage.delete(key: 'token'),
    ]);
  }

  Future<void> deleteSession() async {
    userId = null;
    token = null;
    username = null;
    password = null;

    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: 'userId'),
      storage.delete(key: 'token'),
      storage.delete(key: 'username'),
      storage.delete(key: 'password'),
    ]);
  }
}
