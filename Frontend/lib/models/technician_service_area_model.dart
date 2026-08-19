class TechnicianServiceAreaModel {
  final int technicianId;
  final int cityId;
  final String createdAt;

  const TechnicianServiceAreaModel({
    required this.technicianId,
    required this.cityId,
    required this.createdAt,
  });

  factory TechnicianServiceAreaModel.fromJson(Map<String, dynamic> json) {
    return TechnicianServiceAreaModel(
      technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
      cityId: json['cityId'] is int ? json['cityId'] : int.tryParse(json['cityId']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
