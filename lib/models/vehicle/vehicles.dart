class VehicleDataModel {
  final String makeModel;
  final String plate;
  final String vehicleLength;
  final int id;

  VehicleDataModel({
    required this.makeModel,
    required this.plate,
    required this.vehicleLength,
    required this.id,
  });

  factory VehicleDataModel.fromJson(Map<String, dynamic> json) {
    return VehicleDataModel(
      makeModel: json['makeModel'] ?? '',
      plate: json['plate'] ?? '',
      vehicleLength: json['vehicleLength'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makeModel': makeModel,
      'plate': plate,
      'vehicleLength': vehicleLength,
      'id': id,
    };
  }
}
