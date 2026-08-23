class ServiceQuoteDto {
  final int id;
  final int inspectionId;
  final double amount;
  final String status;
  final String? notes;
  final int revision;
  final String createdAt;
  final String? expiresAt;

  const ServiceQuoteDto({
    required this.id,
    required this.inspectionId,
    required this.amount,
    required this.status,
    this.notes,
    required this.revision,
    required this.createdAt,
    this.expiresAt,
  });

  factory ServiceQuoteDto.fromJson(Map<String, dynamic> json) {
    return ServiceQuoteDto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      inspectionId: json['inspectionId'] is int ? json['inspectionId'] : int.tryParse(json['inspectionId']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      revision: json['revision'] is int ? json['revision'] : int.tryParse(json['revision']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'inspectionId': inspectionId,
        'amount': amount,
        'status': status,
        'notes': notes,
        'revision': revision,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
      };
}

class ServiceQuoteModel {
  final String id;
  final String inspectionId;
  final double amount;
  final String status;
  final String? notes;
  final int revision;
  final String createdAt;
  final String? expiresAt;

  const ServiceQuoteModel({
    required this.id,
    required this.inspectionId,
    required this.amount,
    required this.status,
    this.notes,
    required this.revision,
    required this.createdAt,
    this.expiresAt,
  });

  factory ServiceQuoteModel.fromDto(ServiceQuoteDto dto) => ServiceQuoteModel(
        id: dto.id.toString(),
        inspectionId: dto.inspectionId.toString(),
        amount: dto.amount,
        status: dto.status,
        notes: dto.notes,
        revision: dto.revision,
        createdAt: dto.createdAt,
        expiresAt: dto.expiresAt,
      );

  bool get isPendingCustomer => status == 'PendingCustomer';
  bool get isAccepted => status == 'Accepted';
  bool get isRejected => status == 'Rejected';
  bool get isExpired => status == 'Expired';

  bool get isExpiredByTime {
    final raw = expiresAt;
    if (raw == null || raw.isEmpty) return false;
    final parsed = DateTime.tryParse(raw);
    return parsed != null && parsed.isBefore(DateTime.now().toUtc());
  }
}
