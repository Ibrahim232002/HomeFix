class AddressModel {
  final String id;
  final String userId;
  final String title; // e.g. "المنزل", "المكتب"
  final String governorate;
  final String city;
  final String street;
  final String building;
  final String floor;
  final String apartment;
  final bool isDefault;
  final String? landmark;

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      apartment: json['apartment'] ?? '',
      isDefault: json['isDefault'] ?? false,
      landmark: json['landmark'],
    );
  }
}
