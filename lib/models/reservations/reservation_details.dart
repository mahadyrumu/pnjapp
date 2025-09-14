class ReservationDetailsDataModel {
  final int rsvnId;
  final int claimId;
  final dynamic qrcode;
  final String status;
  final String lotType;
  final String parkingPreference;
  final DateTime pickUpTime;
  final DateTime dropOffTime;
  final String points;
  final String makeModel;
  final String plate;
  final String vehicleLength;
  final String driverFullName;
  final String email;
  final String phone;
  final String paymentTotal;
  final String durationInDay;
  final String paxCount;
  final String paidAtCheckIn;
  final String onlinePayNow;
  final String onlineDiscountAmount;
  final String offlineDiscountAmount;
  final int discountDays;
  final int onlineDiscountedDay;
  final int offlineDiscountedDay;
  final String saving;
  final bool isPaid;

  ReservationDetailsDataModel({
    required this.rsvnId,
    required this.claimId,
    required this.qrcode,
    required this.status,
    required this.lotType,
    required this.parkingPreference,
    required this.pickUpTime,
    required this.dropOffTime,
    required this.points,
    required this.makeModel,
    required this.plate,
    required this.vehicleLength,
    required this.driverFullName,
    required this.email,
    required this.phone,
    required this.paymentTotal,
    required this.durationInDay,
    required this.paxCount,
    required this.paidAtCheckIn,
    required this.onlinePayNow,
    required this.onlineDiscountAmount,
    required this.offlineDiscountAmount,
    required this.discountDays,
    required this.onlineDiscountedDay,
    required this.offlineDiscountedDay,
    required this.saving,
    required this.isPaid,
  });

  factory ReservationDetailsDataModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReservationDetailsDataModel(
        rsvnId: (json['reservation']['id'] ?? 0).toInt(),
        claimId: (json['reservation']['claimId'] ?? 0).toInt(),
        qrcode: json['qrcode'] is String ? json['qrcode'] : "",
        status: json['reservation']['status'] ?? "",
        lotType: json['reservation']['lotType'] ?? "",
        parkingPreference: json['reservation']['parkingPreference'] ?? "",
        pickUpTime: json['reservation']['pickUpTime'] != null
            ? DateTime.parse(json['reservation']['pickUpTime'])
            : DateTime.now(),
        dropOffTime: json['reservation']['dropOffTime'] != null
            ? DateTime.parse(json['reservation']['dropOffTime'])
            : DateTime.now(),
        points: json['reservation']['points']?.toString() ?? "0 Days",
        makeModel: json['reservation']['vehicle']?['makeModel'] ?? "",
        plate: json['reservation']['vehicle']?['plate'] ?? "",
        vehicleLength: json['reservation']['vehicle']?['vehicleLength'] ?? "",
        driverFullName: json['reservation']['driver']?['full_name'] ?? "",
        email: json['reservation']['driver']?['email'] ?? "",
        phone: json['reservation']['driver']?['phone'] ?? "",
        paymentTotal: json['reservation']['paymentTotal'] != null
            ? "\$${json['reservation']['paymentTotal'].toString()}"
            : "\$0.00",
        paidAtCheckIn: json['reservation']['pricing']?.isNotEmpty == true &&
                json['reservation']['pricing'][0]['total'] != null
            ? "\$${json['reservation']['pricing'][0]['total'].toString()}"
            : "\$0.00",
        onlinePayNow: json['reservation']['pricing']?.length > 1 &&
                json['reservation']['pricing'][1]['total'] != null
            ? "\$${json['reservation']['pricing'][1]['total'].toString()}"
            : "\$0.00",
        durationInDay: json['reservation']['durationInDay'] != null
            ? "${json['reservation']['durationInDay']} Days"
            : "0 Days",
        onlineDiscountAmount: json['reservation']['pricing']?.length > 1 &&
                json['reservation']['pricing'][1]['discountAmount'] != null
            ? json['reservation']['pricing'][1]['discountAmount'].toString()
            : "0.00",
        offlineDiscountAmount:
            json['reservation']['pricing']?.isNotEmpty == true &&
                    json['reservation']['pricing'][0]['discountAmount'] != null
                ? json['reservation']['pricing'][0]['discountAmount'].toString()
                : "0.00",
        onlineDiscountedDay: json['reservation']['pricing']?.length > 1 &&
                json['reservation']['pricing'][1]['discountedDay'] != null
            ? (json['reservation']['pricing'][1]['discountedDay']).toInt()
            : 0,
        offlineDiscountedDay:
            json['reservation']['pricing']?.isNotEmpty == true &&
                    json['reservation']['pricing'][0]['discountedDay'] != null
                ? (json['reservation']['pricing'][0]['discountedDay']).toInt()
                : 0,
        discountDays: json['reservation']['discountDays'] != null
            ? (json['reservation']['discountDays']).toInt()
            : 0,
        saving: json['reservation']['save']?.toString() ?? "\$0.00",
        isPaid: json['reservation']?['isPaid'] ?? false,
        paxCount: json['reservation']['paxCount']?.toString() ?? "0",
      );
    } catch (e) {
      print("Error parsing reservation details: $e");
      rethrow;
    }
  }
}
