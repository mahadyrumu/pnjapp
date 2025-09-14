class DriverDataModel {
  final String fullName;
  final String email;
  final String phone;
  final int id;
//create constructor

  DriverDataModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.id,
  });

  factory DriverDataModel.fromJson(Map<String, dynamic> json) {
    return DriverDataModel(
      fullName: json['full_name'] ?? '', // Provide default value if null
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  // // tojson method
  Map<String, dynamic> toJson() {
    return {"fullName": fullName, "email": email, "phone": phone, "id": id};
  }
}
