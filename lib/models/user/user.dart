class User {
  int id;
  String fullName;
  String userName;
  String phone;
  int isAppleAuth;
  int isMetaAuth;
  int isGoogleAuth;

  User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.phone,
    required this.isAppleAuth,
    required this.isMetaAuth,
    required this.isGoogleAuth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? "",
      userName: json['user_name'] ?? "",
      phone: json['phone'] ?? "",
      isAppleAuth: json['is_apple_auth'],
      isMetaAuth: json['is_meta_auth'],
      isGoogleAuth: json['is_google_auth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'user_name': userName,
      'phone': phone,
      'is_apple_auth': isAppleAuth,
      'is_meta_auth': isMetaAuth,
      'is_google_auth': isGoogleAuth,
    };
  }
}
