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
    this.findings,
    required this.createdAt,
    this.completedAt,
  });

  factory InspectionDto.fromJson(Map<String, dynamic> json) {
    return InspectionDto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
      technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      findings: json['findings']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      completedAt: json['completedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'technicianId': technicianId,
        'fee': fee,
        'scheduledAt': scheduledAt,
        'status': status,
        'findings': findings,
        'createdAt': createdAt,
        'completedAt': completedAt,
      };
}

class InspectionModel {
  final String id;
  final String serviceRequestId;
  final String technicianId;
  final double fee;
  final String scheduledAt;
  final String status;
  final String? findings;
  final String createdAt;
  final String? completedAt;

  const InspectionModel({
    required this.id,
    required this.serviceRequestId,
    required this.technicianId,
    required this.fee,
    required this.scheduledAt,
    required this.status,
    this.findings,
    required this.createdAt,
    this.completedAt,
  });

  factory InspectionModel.fromDto(InspectionDto dto) => InspectionModel(
        id: dto.id.toString(),
        serviceRequestId: dto.serviceRequestId.toString(),
        technicianId: dto.technicianId.toString(),
        fee: dto.fee,
        scheduledAt: dto.scheduledAt,
        status: dto.status,
        findings: dto.findings,
        createdAt: dto.createdAt,
        completedAt: dto.completedAt,
      );

  bool get isScheduled => status == 'Scheduled';
  bool get isInProgress => status == 'InProgress';
  bool get isCompleted => status == 'Completed';
}
