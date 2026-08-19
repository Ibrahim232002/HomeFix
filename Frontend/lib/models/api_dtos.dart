// ==========================================
// HOMEFIX ASP.NET CORE OPENAPI DTO SCHEMAS
// ==========================================

// --- Auth DTOs ---
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String role; // "Customer" or "Technician"

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role,
      };
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class AuthResponseDto {
  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final String? email;
  final String? fullName;
  final String? role;

  AuthResponseDto({
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.fullName,
    this.role,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
    );
  }
}

// --- Address DTOs ---
class AddressDto {
  final int id;
  final int customerId;
  final String? label;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? additionalInstructions;
  final bool isDefault;
  final String createdAt;
  final int? governorateId;
  final int? cityId;

  AddressDto({
    required this.id,
    required this.customerId,
    this.label,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.additionalInstructions,
    this.isDefault = false,
    required this.createdAt,
    this.governorateId,
    this.cityId,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      customerId: json['customerId'] is int ? json['customerId'] : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
      label: json['label'],
      fullAddress: json['fullAddress'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      buildingNumber: json['buildingNumber'],
      floorNumber: json['floorNumber'],
      apartmentNumber: json['apartmentNumber'],
      additionalInstructions: json['additionalInstructions'],
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] ?? '',
      governorateId: json['governorateId'] is int ? json['governorateId'] : int.tryParse(json['governorateId']?.toString() ?? ''),
      cityId: json['cityId'] is int ? json['cityId'] : int.tryParse(json['cityId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'label': label,
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
        'buildingNumber': buildingNumber,
        'floorNumber': floorNumber,
        'apartmentNumber': apartmentNumber,
        'additionalInstructions': additionalInstructions,
        'isDefault': isDefault,
        'createdAt': createdAt,
        'governorateId': governorateId,
        'cityId': cityId,
      };
}

class CreateAddressRequest {
  final int customerId;
  final String? label;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? additionalInstructions;
  final bool isDefault;
  final int? governorateId;
  final int? cityId;

  CreateAddressRequest({
    required this.customerId,
    this.label,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.additionalInstructions,
    this.isDefault = false,
    this.governorateId,
    this.cityId,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'label': label,
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
        'buildingNumber': buildingNumber,
        'floorNumber': floorNumber,
        'apartmentNumber': apartmentNumber,
        'additionalInstructions': additionalInstructions,
        'isDefault': isDefault,
        'governorateId': governorateId,
        'cityId': cityId,
      };
}

class UpdateAddressRequest {
  final String? label;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? additionalInstructions;
  final bool isDefault;
  final int? governorateId;
  final int? cityId;

  UpdateAddressRequest({
    this.label,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.additionalInstructions,
    this.isDefault = false,
    this.governorateId,
    this.cityId,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
        'buildingNumber': buildingNumber,
        'floorNumber': floorNumber,
        'apartmentNumber': apartmentNumber,
        'additionalInstructions': additionalInstructions,
        'isDefault': isDefault,
        'governorateId': governorateId,
        'cityId': cityId,
      };
}

// --- City & Governorate DTOs ---
class CityDto {
  final int id;
  final int governorateId;
  final String? name;
  final bool isActive;
  final String createdAt;

  CityDto({
    required this.id,
    required this.governorateId,
    this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) => CityDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        governorateId: json['governorateId'] is int ? json['governorateId'] : int.tryParse(json['governorateId']?.toString() ?? '0') ?? 0,
        name: json['name'],
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'governorateId': governorateId,
        'name': name,
        'isActive': isActive,
        'createdAt': createdAt,
      };
}

class GovernorateDto {
  final int id;
  final String? name;
  final bool isActive;
  final String createdAt;

  GovernorateDto({
    required this.id,
    this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory GovernorateDto.fromJson(Map<String, dynamic> json) => GovernorateDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name'],
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        'createdAt': createdAt,
      };
}

// --- Customer Profile DTOs ---
class CustomerProfileDto {
  final int id;
  final int userId;
  final String? profileImageUrl;
  final String createdAt;

  CustomerProfileDto({
    required this.id,
    required this.userId,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory CustomerProfileDto.fromJson(Map<String, dynamic> json) => CustomerProfileDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
        profileImageUrl: json['profileImageUrl'],
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'profileImageUrl': profileImageUrl,
        'createdAt': createdAt,
      };
}

class CreateCustomerProfileRequest {
  final int userId;
  final String? profileImageUrl;

  CreateCustomerProfileRequest({required this.userId, this.profileImageUrl});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'profileImageUrl': profileImageUrl,
      };
}

class UpdateCustomerProfileRequest {
  final String? profileImageUrl;

  UpdateCustomerProfileRequest({this.profileImageUrl});

  Map<String, dynamic> toJson() => {
        'profileImageUrl': profileImageUrl,
      };
}

// --- Technician Profile DTOs ---
class TechnicianProfileDto {
  final int id;
  final int userId;
  final String? bio;
  final String? profileImageUrl;
  final int? yearsOfExperience;
  final bool isVerified;
  final bool isAvailable;
  final double averageRating;
  final int totalJobs;
  final String createdAt;
  final double? currentLatitude;
  final double? currentLongitude;

  TechnicianProfileDto({
    required this.id,
    required this.userId,
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    required this.isVerified,
    required this.isAvailable,
    required this.averageRating,
    required this.totalJobs,
    required this.createdAt,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory TechnicianProfileDto.fromJson(Map<String, dynamic> json) => TechnicianProfileDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
        bio: json['bio'],
        profileImageUrl: json['profileImageUrl'],
        yearsOfExperience: json['yearsOfExperience'] as int?,
        isVerified: json['isVerified'] ?? false,
        isAvailable: json['isAvailable'] ?? true,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 5.0,
        totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] ?? '',
        currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
        currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
        'yearsOfExperience': yearsOfExperience,
        'isVerified': isVerified,
        'isAvailable': isAvailable,
        'averageRating': averageRating,
        'totalJobs': totalJobs,
        'createdAt': createdAt,
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
      };
}

class CreateTechnicianProfileRequest {
  final int userId;
  final String? bio;
  final String? profileImageUrl;
  final int? yearsOfExperience;
  final bool isVerified;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;

  CreateTechnicianProfileRequest({
    required this.userId,
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    this.isVerified = false,
    this.isAvailable = true,
    this.currentLatitude,
    this.currentLongitude,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
        'yearsOfExperience': yearsOfExperience,
        'isVerified': isVerified,
        'isAvailable': isAvailable,
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
      };
}

class UpdateTechnicianProfileRequest {
  final String? bio;
  final String? profileImageUrl;
  final int? yearsOfExperience;
  final bool? isVerified;
  final bool? isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;

  UpdateTechnicianProfileRequest({
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    this.isVerified,
    this.isAvailable,
    this.currentLatitude,
    this.currentLongitude,
  });

  Map<String, dynamic> toJson() => {
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        if (isVerified != null) 'isVerified': isVerified,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (currentLatitude != null) 'currentLatitude': currentLatitude,
        if (currentLongitude != null) 'currentLongitude': currentLongitude,
      };
}

// --- Service & ServicePricing DTOs ---
class ServiceDto {
  final int id;
  final String? name;
  final String? description;
  final bool isActive;

  ServiceDto({
    required this.id,
    this.name,
    this.description,
    required this.isActive,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) => ServiceDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name'],
        description: json['description'],
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isActive': isActive,
      };
}

class ServicePricingDto {
  final int id;
  final int serviceId;
  final int? cityId;
  final double visitFee;
  final double? minimumPrice;
  final bool isActive;
  final String createdAt;

  ServicePricingDto({
    required this.id,
    required this.serviceId,
    this.cityId,
    required this.visitFee,
    this.minimumPrice,
    required this.isActive,
    required this.createdAt,
  });

  factory ServicePricingDto.fromJson(Map<String, dynamic> json) => ServicePricingDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceId: json['serviceId'] is int ? json['serviceId'] : int.tryParse(json['serviceId']?.toString() ?? '0') ?? 0,
        cityId: json['cityId'] is int ? json['cityId'] : int.tryParse(json['cityId']?.toString() ?? ''),
        visitFee: (json['visitFee'] as num?)?.toDouble() ?? 0.0,
        minimumPrice: (json['minimumPrice'] as num?)?.toDouble(),
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'cityId': cityId,
        'visitFee': visitFee,
        'minimumPrice': minimumPrice,
        'isActive': isActive,
        'createdAt': createdAt,
      };
}
