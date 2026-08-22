class ServiceQuoteModel {
  final String id;
  final String inspectionId;
  final double amount;
  final String status;
  final String? notes;
  final int revision;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const ServiceQuoteModel({
    required this.id,
    required this.inspectionId,
    required this.amount,
    required this.status,
    required this.notes,
    required this.revision,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isPendingCustomer => status == 'PendingCustomer' && !(expiresAt?.isBefore(DateTime.now()) ?? false);
}
