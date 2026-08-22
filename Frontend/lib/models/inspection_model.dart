class InspectionModel {
  final String id;
  final String serviceRequestId;
  final String technicianId;
  final double fee;
  final DateTime scheduledAt;
  final String status;
  final String? findings;
  final DateTime createdAt;
  final DateTime? completedAt;

  const InspectionModel({
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

  bool get isCompleted => status == 'Completed';
  bool get isTerminal => status == 'Completed' || status == 'Cancelled' || status == 'NoShow';
}
