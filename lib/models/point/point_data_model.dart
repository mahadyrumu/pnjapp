class PointDataModel {
  bool? success;
  Data? data;

  PointDataModel({this.success, this.data});

  factory PointDataModel.fromJson(Map<String, dynamic> json) {
    return PointDataModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success ?? false,
      'data': data?.toJson(),
    };
  }
}

class Data {
  List<Transaction>? lot1Wallet;
  List<Transaction>? lot2Wallet;
  List<Transaction>? lot1Reward;
  List<Transaction>? lot2Reward;
  List<Transaction>? lot1Prepaid;
  List<Transaction>? lot2Prepaid;

  Data({
    this.lot1Wallet,
    this.lot2Wallet,
    this.lot1Reward,
    this.lot2Reward,
    this.lot1Prepaid,
    this.lot2Prepaid,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      lot1Wallet: _parseTransactions(json['lot1Wallet']),
      lot2Wallet: _parseTransactions(json['lot2Wallet']),
      lot1Reward: _parseTransactions(json['lot1Reward']),
      lot2Reward: _parseTransactions(json['lot2Reward']),
      lot1Prepaid: _parseTransactions(json['lot1Prepaid']),
      lot2Prepaid: _parseTransactions(json['lot2Prepaid']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lot1Wallet': lot1Wallet?.map((e) => e.toJson()).toList(),
      'lot2Wallet': lot2Wallet?.map((e) => e.toJson()).toList(),
      'lot1Reward': lot1Reward?.map((e) => e.toJson()).toList(),
      'lot2Reward': lot2Reward?.map((e) => e.toJson()).toList(),
      'lot1Prepaid': lot1Prepaid?.map((e) => e.toJson()).toList(),
      'lot2Prepaid': lot2Prepaid?.map((e) => e.toJson()).toList(),
    };
  }

  static List<Transaction> _parseTransactions(dynamic jsonList) {
    if (jsonList == null || jsonList is! List) {
      return [];
    }
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }
}

class Transaction {
  int? id;
  int? isDeleted;
  int? version;
  DateTime? createdDate;
  DateTime? lastModifiedDate;
  String? description;
  num? newBalance;
  num? oldBalance;
  String? transactionType;
  String? triggerType;
  int? createdById;
  int? lastModifiedById;
  int? prePaidPackageId;
  int? prePaidWalletId;
  int? reservationId;
  String? comment;
  int? packagePricingId;

  Transaction({
    this.id,
    this.isDeleted,
    this.version,
    this.createdDate,
    this.lastModifiedDate,
    this.description,
    this.newBalance,
    this.oldBalance,
    this.transactionType,
    this.triggerType,
    this.createdById,
    this.lastModifiedById,
    this.prePaidPackageId,
    this.prePaidWalletId,
    this.reservationId,
    this.comment,
    this.packagePricingId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      isDeleted: json['isDeleted'] ?? 0,
      version: json['version'] ?? 0,
      createdDate: DateTime.tryParse(json['createdDate'] ?? ''),
      lastModifiedDate: DateTime.tryParse(json['lastModifiedDate'] ?? ''),
      description: json['description'] ?? '',
      newBalance: _toNum(json['newBalance']), // Updated method
      oldBalance: _toNum(json['oldBalance']), // Updated method
      transactionType: json['transactionType'] ?? '',
      triggerType: json['triggerType'] ?? '',
      createdById: json['createdBy_id'] ?? 0,
      lastModifiedById: json['lastModifiedBy_id'],
      prePaidPackageId: json['prePaidPackage_id'] ?? 0,
      prePaidWalletId: json['prePaidWallet_id'] ?? 0,
      reservationId: json['reservation_id'],
      comment: json['comment'] ?? '',
      packagePricingId: json['packagePricing_id'] ?? 0,
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value; // Already a number (int or double)
    }
    if (value is String) {
      return num.tryParse(value) ?? 0; // Convert string to num
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'isDeleted': isDeleted ?? 0,
      'version': version ?? 0,
      'createdDate': createdDate?.toIso8601String(),
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
      'description': description ?? '',
      'newBalance': newBalance ?? 0,
      'oldBalance': oldBalance ?? 0,
      'transactionType': transactionType ?? '',
      'triggerType': triggerType ?? '',
      'createdBy_id': createdById ?? 0,
      'lastModifiedBy_id': lastModifiedById,
      'prePaidPackage_id': prePaidPackageId ?? 0,
      'prePaidWallet_id': prePaidWalletId ?? 0,
      'reservation_id': reservationId,
      'comment': comment ?? '',
      'packagePricing_id': packagePricingId ?? 0,
    };
  }

  // static double _toDouble(dynamic value) {
  //   if (value == null) {
  //     return 0.0;
  //   }
  //   if (value is int) {
  //     return value.toDouble();
  //   }
  //   if (value is double) {
  //     return value;
  //   }
  //   return 0.0;
  // }
  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is int) {
      return value;
    }
    return 0;
  }
}
