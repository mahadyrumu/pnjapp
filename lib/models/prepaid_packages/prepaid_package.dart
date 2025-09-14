class PrepaidPackage {
  final int id;
  final int isDeleted;
  final int version;
  final String createdDate;
  final String lastModifiedDate;
  final int days;
  final int expirationDurationInMonths;
  final String lotType;
  final String price;
  final int savings;
  final int createdById;
  final int lastModifiedById;

  PrepaidPackage({
    required this.id,
    required this.isDeleted,
    required this.version,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.days,
    required this.expirationDurationInMonths,
    required this.lotType,
    required this.price,
    required this.savings,
    required this.createdById,
    required this.lastModifiedById,
  });

  factory PrepaidPackage.fromJson(Map<String, dynamic> json) {
    return PrepaidPackage(
      id: json['id'],
      isDeleted: json['isDeleted'],
      version: json['version'],
      createdDate: json['createdDate'],
      lastModifiedDate: json['lastModifiedDate'],
      days: json['days'],
      expirationDurationInMonths: json['expirationDurationInMonths'],
      lotType: json['lotType'],
      price: json['price'],
      savings: json['savings'],
      createdById: json['createdBy_id'],
      lastModifiedById: json['lastModifiedBy_id'],
    );
  }
}
