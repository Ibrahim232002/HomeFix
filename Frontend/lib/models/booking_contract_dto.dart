class BookingContractDto {
  final int id;
  final int serviceRequestId;
  final int technicianId;
  final String status;
  final double? agreedPrice;
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final double? finalPrice;
  final String? technicianNotes;

  const BookingContractDto({
    required this.id,
    required this.serviceRequestId,
    required this.technicianId,
    required this.status,
    this.agreedPrice,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.finalPrice,
    this.technicianNotes,
  });

  factory BookingContractDto.fromJson(Map<String, dynamic> json) {
    return BookingContractDto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      serviceRequestId: json['serviceRequestId'] is int
          ? json['serviceRequestId']
          : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
      technicianId: json['technicianId'] is int
          ? json['technicianId']
          : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Unknown',
      agreedPrice: (json['agreedPrice'] as num?)?.toDouble(),
      acceptedAt: json['acceptedAt']?.toString(),
      arrivedAt: json['arrivedAt']?.toString(),
      startedAt: json['startedAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      technicianNotes: json['technicianNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'technicianId': technicianId,
        'status': status,
        'agreedPrice': agreedPrice,
        'acceptedAt': acceptedAt,
        'arrivedAt': arrivedAt,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'finalPrice': finalPrice,
        'technicianNotes': technicianNotes,
      };
}
