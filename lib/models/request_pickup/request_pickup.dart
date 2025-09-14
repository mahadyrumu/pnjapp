class RequestPickupDataModel {
  final int id;
  final int claimId;
  final String dateAdded;
  final String dateUpDated;
  final String parkingStatus;
  final int dropOffDetailsId;
  final int parkingLocationId;
  final int pickupDetailsId;
  final int pricingDetailsId;
  final int reservationId;
  final bool helpedCustomer;

  RequestPickupDataModel({
    required this.id,
    required this.claimId,
    required this.dateAdded,
    required this.dateUpDated,
    required this.parkingStatus,
    required this.dropOffDetailsId,
    required this.parkingLocationId,
    required this.pickupDetailsId,
    required this.pricingDetailsId,
    required this.reservationId,
    required this.helpedCustomer,
  });

  factory RequestPickupDataModel.fromJson(Map<String, dynamic> json) {
    return RequestPickupDataModel(
      id: json['id'] ?? 0,
      claimId: json['claimId'] ?? 0,
      dateAdded: json['dateAdded'] ?? '',
      dateUpDated: json['dateUpDated'] ?? '',
      parkingStatus: json['parkingStatus'] ?? '',
      dropOffDetailsId: json['dropOffDetails_id'] ?? 0,
      parkingLocationId: json['parkingLocation_id'] ?? 0,
      pickupDetailsId: json['pickupDetails_id'] ?? 0,
      pricingDetailsId: json['pricingDetails_id'] ?? 0,
      reservationId: json['reservation_id'] ?? 0,
      helpedCustomer:
          json['helpedCustomer'] == 1, // Adjusted to convert int to bool
    );
  }
}
