class InspectionDto {
  final int id;
  final int serviceRequestId;
  final int technicianId;
  final double fee;
  final String scheduledAt;
  final String status;
  final String? findings;
  final String createdAt;
  final String? completedAt;

  const InspectionDto({
    required this.id,
    required this.serviceRequestId,
    required this.technicianId,
    required this.fee,
    required this.scheduledAt,
    required this.status,
    required this.findings,
    required this.createdAt,
    required this.completedAt,
  });

  factory InspectionDto.fromJson(Map<String, dynamic> json) => InspectionDto(
        id: (json['id'] as num?)?.toInt() ?? 0,
        serviceRequestId: (json['serviceRequestId'] as num?)?.toInt() ?? 0,
        technicianId: (json['technicianId'] as num?)?.toInt() ?? 0,
        fee: (json['fee'] as num?)?.toDouble() ?? 0,
        scheduledAt: json['scheduledAt']?.toString() ?? '',
        status: json['status']?.toString() ?? 'Scheduled',
        findings: json['findings']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
        completedAt: json['completedAt']?.toString(),
      );
}
