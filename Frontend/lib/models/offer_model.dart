class ServiceRequestOfferModel {
  final String id;
  final String serviceRequestId;
  final String serviceId;
  final int pricingMode;
  final String technicianId;
  final String technicianName;
  final double proposedPrice;
  final String technicianNote;
  final String status;
  final String createdAt;
  final String? expiresAt;
  final String? respondedAt;

  const ServiceRequestOfferModel({
    required this.id,
    required this.serviceRequestId,
    this.serviceId = '',
    this.pricingMode = 0,
    required this.technicianId,
    required this.technicianName,
    required this.proposedPrice,
    required this.technicianNote,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
  });

  factory ServiceRequestOfferModel.fromJson(Map<String, dynamic> json) {
    final pricingModeValue = json['pricingMode'];
    return ServiceRequestOfferModel(
      id: json['id']?.toString() ?? '',
      serviceRequestId: json['serviceRequestId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      pricingMode: pricingModeValue is num ? pricingModeValue.toInt() : int.tryParse(pricingModeValue?.toString() ?? '') ?? 0,
      technicianId: json['technicianId']?.toString() ?? '',
      technicianName: json['technicianName']?.toString() ?? 'الفني',
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? 0,
      technicianNote: json['technicianNote']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString(),
      respondedAt: json['respondedAt']?.toString(),
    );
  }
}
