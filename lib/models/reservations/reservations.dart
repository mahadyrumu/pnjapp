import 'package:intl/intl.dart';

class ReservationDataModel {
  final int rsvnId;
  final int claimId;
  final String driver;
  final String driverEmail;
  final String vehicle;
  final String plate;
  final DateTime dropOffTime;
  final DateTime pickUpTime;
  final String status;
  final String phone;

  ReservationDataModel({
    required this.rsvnId,
    required this.claimId,
    required this.driver,
    required this.driverEmail,
    required this.vehicle,
    required this.plate,
    required this.dropOffTime,
    required this.pickUpTime,
    required this.status,
    required this.phone,
  });

  factory ReservationDataModel.fromJson(Map<String, dynamic> json) {
    return ReservationDataModel(
      rsvnId: json['id'] as int? ?? 0,
      claimId: json['claimId'] ?? 0,
      driver: json['driver'] != null && json['driver']['full_name'] is String
          ? json['driver']['full_name'] as String
          : '',
      driverEmail: json['driver'] != null && json['driver']['email'] is String
          ? json['driver']['email'] as String
          : '',
      vehicle: json['vehicle'] != null && json['vehicle']['makeModel'] is String
          ? json['vehicle']['makeModel'] as String
          : '',
      plate: json['vehicle'] != null && json['vehicle']['plate'] is String
          ? json['vehicle']['plate'] as String
          : '',
      dropOffTime: json['dropOffTime'] != null
          ? DateFormat('MM/dd/yyyy hh:mm a')
              .parse(json['dropOffTime'] as String)
          : DateTime.now(),
      pickUpTime: json['pickUpTime'] != null
          ? DateFormat('MM/dd/yyyy hh:mm a').parse(json['pickUpTime'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? '',
      phone: json['driver'] != null && json['driver']['phone'] is String
          ? json['driver']['phone'] as String
          : '',
    );
  }
}
