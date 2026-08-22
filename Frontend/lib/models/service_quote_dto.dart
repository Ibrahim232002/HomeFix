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
    required this.notes,
    required this.revision,
    required this.createdAt,
    required this.expiresAt,
  });

  factory ServiceQuoteDto.fromJson(Map<String, dynamic> json) => ServiceQuoteDto(
        id: (json['id'] as num?)?.toInt() ?? 0,
        inspectionId: (json['inspectionId'] as num?)?.toInt() ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? 'PendingCustomer',
        notes: json['notes']?.toString(),
        revision: (json['revision'] as num?)?.toInt() ?? 1,
        createdAt: json['createdAt']?.toString() ?? '',
        expiresAt: json['expiresAt']?.toString(),
      );
}
