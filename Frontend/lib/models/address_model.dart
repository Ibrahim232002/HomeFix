class AddressModel {
  final String id;
  final String userId;
  final String title;
  final String governorate;
  final String city;
  final String street;
  final String building;
  final String floor;
  final String apartment;
  final bool isDefault;
  final String? landmark;
  final int? governorateId;
  final int? cityId;

  AddressModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.governorate,
    required this.city,
    required this.street,
    required this.building,
    required this.floor,
    required this.apartment,
    this.isDefault = false,
    this.landmark,
    this.governorateId,
    this.cityId,
  });

  String get fullAddressDescription =>
      '$governorate، $city، $street، $building، طابق $floor، شقة $apartment ${landmark != null && landmark!.isNotEmpty ? "($landmark)" : ""}';

  AddressModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? governorate,
    String? city,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    bool? isDefault,
    String? landmark,
    int? governorateId,
    int? cityId,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      street: street ?? this.street,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      isDefault: isDefault ?? this.isDefault,
      landmark: landmark ?? this.landmark,
      governorateId: governorateId ?? this.governorateId,
      cityId: cityId ?? this.cityId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'governorate': governorate,
        'city': city,
        'street': street,
        'building': building,
        'floor': floor,
        'apartment': apartment,
        'isDefault': isDefault,
        'landmark': landmark,
        'governorateId': governorateId,
        'cityId': cityId,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      apartment: json['apartment']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
      landmark: json['landmark']?.toString(),
      governorateId: json['governorateId'] is int
          ? json['governorateId']
          : int.tryParse(json['governorateId']?.toString() ?? ''),
      cityId: json['cityId'] is int
          ? json['cityId']
          : int.tryParse(json['cityId']?.toString() ?? ''),
    );
  }
}
