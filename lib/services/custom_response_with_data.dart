class CustomResponseWithData {
  final bool success;
  final String message;
  var data;

  CustomResponseWithData(
      {required this.success, required this.message, required this.data});

  factory CustomResponseWithData.fromJson(Map<String, dynamic> json) {
    return CustomResponseWithData(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}
