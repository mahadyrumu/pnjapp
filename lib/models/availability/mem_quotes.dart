class GetMemQuote {
  final bool success;
  final Map<String, LotData> data;

  GetMemQuote({required this.success, required this.data});

  factory GetMemQuote.fromJson(Map<String, dynamic> json) {
    return GetMemQuote(
      success: json['success'] ?? false, // Default value for success
      data: (json['data'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LotData.fromJson(value)),
      ),
    );
  }
}

class LotData {
  final Map<String, ParkingOption> options;

  LotData({required this.options});

  factory LotData.fromJson(Map<String, dynamic> json) {
    return LotData(
      options: (json['VALET'] != null
              ? {'VALET': ParkingOption.fromJson(json['VALET'])}
              : {})
          .map((key, value) => MapEntry(key, value))
        ..addAll(
          json.containsKey('SELF')
              ? {'SELF': ParkingOption.fromJson(json['SELF'])}
              : {},
        ),
    );
  }
}

class ParkingOption {
  final String cityTax;
  final String portFee;
  final String currency;
  final String lotType;
  final String extraFee;
  final bool? isCouponValid;
  final OnlinePricing online;
  final OnlinePricing onlineReference;
  final OnlinePricing nonOnline;
  final OnlinePricing nonOnlineReference;
  final OnlinePricing onlineAnon;
  final OnlinePricing nonOnlineAnon;

  ParkingOption({
    required this.cityTax,
    required this.portFee,
    required this.currency,
    required this.lotType,
    required this.extraFee,
    required this.isCouponValid,
    required this.online,
    required this.onlineReference,
    required this.nonOnline,
    required this.nonOnlineReference,
    required this.onlineAnon,
    required this.nonOnlineAnon,
  });

  factory ParkingOption.fromJson(Map<String, dynamic> json) {
    return ParkingOption(
      cityTax: _convertToString(json['cityTax']),
      portFee: _convertToString(json['portFee']),
      currency: _convertToString(json['currency']),
      lotType: _convertToString(json['lotType']),
      extraFee: _convertToString(json['extraFee']),
      isCouponValid: json['isCouponValid'], // Nullable
      online: OnlinePricing.fromJson(json['online']),
      onlineReference: OnlinePricing.fromJson(json['onlineReference']),
      nonOnline: OnlinePricing.fromJson(json['nonOnline']),
      nonOnlineReference: OnlinePricing.fromJson(json['nonOnlineReference']),
      onlineAnon: OnlinePricing.fromJson(json['onlineAnon']),
      nonOnlineAnon: OnlinePricing.fromJson(json['nonOnlineAnon']),
    );
  }

  static String _convertToString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is int) {
      return value.toString();
    } else if (value is double) {
      return value.toString();
    } else {
      return ''; // Return empty string
    }
  }
}

class OnlinePricing {
  final double averageRate;
  final double couponDiscountAmount;
  final bool isAMember;
  final String paymentType;
  final double stateTax;
  final double extraAmount;
  final double subTotal;
  final double total;
  final int points;
  final double markUpPercent;
  final int walletDays;
  final double durationInDay;
  final double affectedAverageRate;
  final String? couponCode;
  final int couponDiscountedDays;
  final double savedAmountByBeingMember;

  OnlinePricing({
    required this.averageRate,
    required this.couponDiscountAmount,
    required this.isAMember,
    required this.paymentType,
    required this.stateTax,
    required this.extraAmount,
    required this.subTotal,
    required this.total,
    required this.points,
    required this.markUpPercent,
    required this.walletDays,
    required this.durationInDay,
    required this.affectedAverageRate,
    this.couponCode,
    required this.couponDiscountedDays,
    required this.savedAmountByBeingMember,
  });

  factory OnlinePricing.fromJson(Map<String, dynamic> json) {
    return OnlinePricing(
      averageRate: _convertToDouble(json['averageRate']),
      couponDiscountAmount: _convertToDouble(json['couponDiscountAmount']),
      isAMember: json['isAMember'] ?? false,
      paymentType: json['paymentType'] ?? '',
      stateTax: _convertToDouble(json['stateTax']),
      extraAmount: _convertToDouble(json['extraAmount']),
      subTotal: _convertToDouble(json['subTotal']),
      total: _convertToDouble(json['total']),
      points: json['points'] ?? 0,
      markUpPercent: _convertToDouble(json['markUpPercent']),
      walletDays: json['walletDays'] ?? 0,
      durationInDay: _convertToDouble(json['durationInDay']),
      affectedAverageRate: _convertToDouble(json['affectedAverageRate']),
      couponCode: json['couponCode'],
      couponDiscountedDays: json['couponDiscountedDays'] ?? 0,
      savedAmountByBeingMember:
          _convertToDouble(json['savedAmountByBeingMember']),
    );
  }

  static double _convertToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else {
      return 0.0; // Return 0.0 for unsupported types
    }
  }
}
