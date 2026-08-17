class ServiceRequestOfferModel {
  final String id;
  final String serviceRequestId;
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
    return ServiceRequestOfferModel(
      id: json['id']?.toString() ?? '',
      serviceRequestId: json['serviceRequestId']?.toString() ?? '',
      technicianId: json['technicianId']?.toString() ?? '',
      technicianName: json['technicianName']?.toString() ?? '',
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? 0,
      technicianNote: json['technicianNote']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString(),
      respondedAt: json['respondedAt']?.toString(),
    );
  }
}
