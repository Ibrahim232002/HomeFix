class CityModel {
  final String id;
  final String governorateId;
  final String nameAr;
  final String nameEn;

  CityModel({
    required this.id,
    required this.governorateId,
    required this.nameAr,
    required this.nameEn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'governorateId': governorateId,
        'nameAr': nameAr,
        'nameEn': nameEn,
      };

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json['id'] ?? '',
        governorateId: json['governorateId'] ?? '',
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
      );
}

class GovernorateModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<CityModel> cities;

  GovernorateModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.cities,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'cities': cities.map((c) => c.toJson()).toList(),
      };

  factory GovernorateModel.fromJson(Map<String, dynamic> json) =>
      GovernorateModel(
        id: json['id'] ?? '',
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
        cities: (json['cities'] as List<dynamic>? ?? [])
            .map((c) => CityModel.fromJson(c))
            .toList(),
      );
}
