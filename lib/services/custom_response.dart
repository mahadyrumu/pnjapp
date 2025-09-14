class CustomResponse {
  final bool success;
  final String message;

  CustomResponse({required this.success, required this.message});

  factory CustomResponse.fromJson(Map<String, dynamic> json) {
    return CustomResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}
