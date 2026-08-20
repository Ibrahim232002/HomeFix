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
  final int? categoryId;
  final String? categoryName;
  final List<int> serviceIds;

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
    this.categoryId,
    this.categoryName,
    this.serviceIds = const [],
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
        categoryId: json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId']?.toString() ?? ''),
        categoryName: json['categoryName']?.toString(),
        serviceIds: (json['serviceIds'] as List<dynamic>? ?? [])
            .map((value) => value is int ? value : int.tryParse(value.toString()))
            .whereType<int>()
            .toList(),
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
        'categoryId': categoryId,
        'categoryName': categoryName,
        'serviceIds': serviceIds,
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
  final int? categoryId;
  final List<int>? serviceIds;

  UpdateTechnicianProfileRequest({
    this.bio,
    this.profileImageUrl,
    this.yearsOfExperience,
    this.isVerified,
    this.isAvailable,
    this.currentLatitude,
    this.currentLongitude,
    this.categoryId,
    this.serviceIds,
  });

  Map<String, dynamic> toJson() => {
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        if (isVerified != null) 'isVerified': isVerified,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (currentLatitude != null) 'currentLatitude': currentLatitude,
        if (currentLongitude != null) 'currentLongitude': currentLongitude,
        if (categoryId != null) 'categoryId': categoryId,
        if (serviceIds != null) 'serviceIds': serviceIds,
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

// --- ServiceRequest DTOs ---
class ServiceRequestDto {
  final int id;
  final int customerId;
  final int serviceId;
  final int addressId;
  final String? description;
  final String? preferredDate;
  final String? preferredTime;
  final String? status;
  final double visitFee;
  final String createdAt;
  final String? updatedAt;

  ServiceRequestDto({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.addressId,
    this.description,
    this.preferredDate,
    this.preferredTime,
    this.status,
    required this.visitFee,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequestDto.fromJson(Map<String, dynamic> json) => ServiceRequestDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        customerId: json['customerId'] is int ? json['customerId'] : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
        serviceId: json['serviceId'] is int ? json['serviceId'] : int.tryParse(json['serviceId']?.toString() ?? '0') ?? 0,
        addressId: json['addressId'] is int ? json['addressId'] : int.tryParse(json['addressId']?.toString() ?? '0') ?? 0,
        description: json['description'],
        preferredDate: json['preferredDate'],
        preferredTime: json['preferredTime'],
        status: json['status'],
        visitFee: (json['visitFee'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'serviceId': serviceId,
        'addressId': addressId,
        'description': description,
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'status': status,
        'visitFee': visitFee,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CreateServiceRequestRequest {
  final int customerId;
  final int serviceId;
  final int addressId;
  final String? description;
  final String? preferredDate;
  final String? preferredTime;
  final String? status;
  final double visitFee;

  CreateServiceRequestRequest({
    required this.customerId,
    required this.serviceId,
    required this.addressId,
    this.description,
    this.preferredDate,
    this.preferredTime,
    this.status = 'Pending',
    required this.visitFee,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'serviceId': serviceId,
        'addressId': addressId,
        'description': description,
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'status': status,
        'visitFee': visitFee,
      };
}

// --- ServiceRequestFile & StatusHistory DTOs ---
class ServiceRequestFileDto {
  final int id;
  final int serviceRequestId;
  final String? fileUrl;
  final String? fileType;
  final String uploadedAt;

  ServiceRequestFileDto({
    required this.id,
    required this.serviceRequestId,
    this.fileUrl,
    this.fileType,
    required this.uploadedAt,
  });

  factory ServiceRequestFileDto.fromJson(Map<String, dynamic> json) => ServiceRequestFileDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        fileUrl: json['fileUrl'],
        fileType: json['fileType'],
        uploadedAt: json['uploadedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'uploadedAt': uploadedAt,
      };
}

class CreateServiceRequestFileRequest {
  final int serviceRequestId;
  final String? fileUrl;
  final String? fileType;

  CreateServiceRequestFileRequest({
    required this.serviceRequestId,
    this.fileUrl,
    this.fileType,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'fileUrl': fileUrl,
        'fileType': fileType,
      };
}

class ServiceRequestStatusHistoryDto {
  final int id;
  final int serviceRequestId;
  final String? oldStatus;
  final String? newStatus;
  final int changedByUserId;
  final String changedAt;

  ServiceRequestStatusHistoryDto({
    required this.id,
    required this.serviceRequestId,
    this.oldStatus,
    this.newStatus,
    required this.changedByUserId,
    required this.changedAt,
  });

  factory ServiceRequestStatusHistoryDto.fromJson(Map<String, dynamic> json) => ServiceRequestStatusHistoryDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        oldStatus: json['oldStatus'],
        newStatus: json['newStatus'],
        changedByUserId: json['changedByUserId'] is int ? json['changedByUserId'] : int.tryParse(json['changedByUserId']?.toString() ?? '0') ?? 0,
        changedAt: json['changedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'changedByUserId': changedByUserId,
        'changedAt': changedAt,
      };
}

class CreateServiceRequestStatusHistoryRequest {
  final int serviceRequestId;
  final String? oldStatus;
  final String? newStatus;
  final int changedByUserId;

  CreateServiceRequestStatusHistoryRequest({
    required this.serviceRequestId,
    this.oldStatus,
    this.newStatus,
    required this.changedByUserId,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'changedByUserId': changedByUserId,
      };
}

// --- Booking DTOs ---
class BookingDto {
  final int id;
  final int serviceRequestId;
  final int technicianId;
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final double? finalPrice;
  final String? technicianNotes;

  BookingDto({
    required this.id,
    required this.serviceRequestId,
    required this.technicianId,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.finalPrice,
    this.technicianNotes,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) => BookingDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        acceptedAt: json['acceptedAt'],
        arrivedAt: json['arrivedAt'],
        startedAt: json['startedAt'],
        completedAt: json['completedAt'],
        finalPrice: (json['finalPrice'] as num?)?.toDouble(),
        technicianNotes: json['technicianNotes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'technicianId': technicianId,
        'acceptedAt': acceptedAt,
        'arrivedAt': arrivedAt,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'finalPrice': finalPrice,
        'technicianNotes': technicianNotes,
      };
}

class CreateBookingRequest {
  final int serviceRequestId;
  final int technicianId;

  CreateBookingRequest({
    required this.serviceRequestId,
    required this.technicianId,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'technicianId': technicianId,
      };
}

class UpdateBookingRequest {
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final double? finalPrice;
  final String? technicianNotes;

  UpdateBookingRequest({
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.finalPrice,
    this.technicianNotes,
  });

  Map<String, dynamic> toJson() => {
        if (acceptedAt != null) 'acceptedAt': acceptedAt,
        if (arrivedAt != null) 'arrivedAt': arrivedAt,
        if (startedAt != null) 'startedAt': startedAt,
        if (completedAt != null) 'completedAt': completedAt,
        if (finalPrice != null) 'finalPrice': finalPrice,
        if (technicianNotes != null) 'technicianNotes': technicianNotes,
      };
}

// --- Payment DTOs ---
class PaymentDto {
  final int id;
  final int serviceRequestId;
  final double amount;
  final String? currency;
  final String? paymentType;
  final String? paymentMethod;
  final String? status;
  final String? transactionReference;
  final String? gatewayOrderId;
  final String? paidAt;
  final String createdAt;

  PaymentDto({
    required this.id,
    required this.serviceRequestId,
    required this.amount,
    this.currency = 'EGP',
    this.paymentType,
    this.paymentMethod,
    this.status,
    this.transactionReference,
    this.gatewayOrderId,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) => PaymentDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] ?? 'EGP',
        paymentType: json['paymentType'],
        paymentMethod: json['paymentMethod'],
        status: json['status'],
        transactionReference: json['transactionReference']?.toString(),
        gatewayOrderId: json['gatewayOrderId']?.toString(),
        paidAt: json['paidAt'],
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'currency': currency,
        'paymentType': paymentType,
        'paymentMethod': paymentMethod,
        'status': status,
        'transactionReference': transactionReference,
        'gatewayOrderId': gatewayOrderId,
        'paidAt': paidAt,
        'createdAt': createdAt,
      };
}

class CreatePaymentRequest {
  final int serviceRequestId;
  final double amount;
  final String? paymentType;
  final String? paymentMethod;

  CreatePaymentRequest({
    required this.serviceRequestId,
    required this.amount,
    this.paymentType,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'paymentType': paymentType,
        'paymentMethod': paymentMethod,
      };
}

class UpdatePaymentRequest {
  final String? status;
  final String? transactionReference;
  final String? paidAt;

  UpdatePaymentRequest({this.status, this.transactionReference, this.paidAt});

  Map<String, dynamic> toJson() => {
        if (status != null) 'status': status,
        if (transactionReference != null) 'transactionReference': transactionReference,
        if (paidAt != null) 'paidAt': paidAt,
      };
}

/// Request sent by client to initiate real Egyptian payment gateway flow (Paymob)
class InitiatePaymentRequest {
  final int serviceRequestId;
  final String paymentMethod; // 'Card', 'MobileWallet', 'CashOnDelivery'
  final String? walletPhoneNumber; // Required for Mobile Wallets (e.g. Vodafone Cash)
  final String? paymentType; // 'VisitFee', 'FullService'

  InitiatePaymentRequest({
    required this.serviceRequestId,
    required this.paymentMethod,
    this.walletPhoneNumber,
    this.paymentType = 'FullService',
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'paymentMethod': paymentMethod,
        if (walletPhoneNumber != null && walletPhoneNumber!.isNotEmpty)
          'walletPhoneNumber': walletPhoneNumber,
        'paymentType': paymentType,
      };
}

/// Gateway session response returned by ASP.NET Core backend to client
class InitiatePaymentResponse {
  final int paymentId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? paymentToken;
  final String? iframeUrl;
  final String? redirectUrl;
  final String? gatewayOrderId;
  final String? transactionReference;
  final bool isCash;
  final String message;

  InitiatePaymentResponse({
    required this.paymentId,
    required this.amount,
    this.currency = 'EGP',
    required this.paymentMethod,
    required this.status,
    this.paymentToken,
    this.iframeUrl,
    this.redirectUrl,
    this.gatewayOrderId,
    this.transactionReference,
    this.isCash = false,
    this.message = '',
  });

  factory InitiatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      InitiatePaymentResponse(
        paymentId: json['paymentId'] is int ? json['paymentId'] : int.tryParse(json['paymentId']?.toString() ?? '0') ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] ?? 'EGP',
        paymentMethod: json['paymentMethod'] ?? 'Card',
        status: json['status'] ?? 'Pending',
        paymentToken: json['paymentToken']?.toString(),
        iframeUrl: json['iframeUrl']?.toString(),
        redirectUrl: json['redirectUrl']?.toString(),
        gatewayOrderId: json['gatewayOrderId']?.toString(),
        transactionReference: json['transactionReference']?.toString(),
        isCash: json['isCash'] ?? false,
        message: json['message'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'status': status,
        'paymentToken': paymentToken,
        'iframeUrl': iframeUrl,
        'redirectUrl': redirectUrl,
        'gatewayOrderId': gatewayOrderId,
        'transactionReference': transactionReference,
        'isCash': isCash,
        'message': message,
      };
}

/// Server verification response after polling or webhook confirmation
class VerifyPaymentResponse {
  final int paymentId;
  final int serviceRequestId;
  final String status; // 'Paid', 'Pending', 'Failed', 'Cancelled'
  final bool isSuccess;
  final String? transactionReference;
  final String? paidAt;
  final String message;

  VerifyPaymentResponse({
    required this.paymentId,
    required this.serviceRequestId,
    required this.status,
    required this.isSuccess,
    this.transactionReference,
    this.paidAt,
    this.message = '',
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) =>
      VerifyPaymentResponse(
        paymentId: json['paymentId'] is int ? json['paymentId'] : int.tryParse(json['paymentId']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? 'Pending',
        isSuccess: json['isSuccess'] ?? (json['status']?.toString().toLowerCase() == 'paid'),
        transactionReference: json['transactionReference']?.toString(),
        paidAt: json['paidAt']?.toString(),
        message: json['message'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'serviceRequestId': serviceRequestId,
        'status': status,
        'isSuccess': isSuccess,
        'transactionReference': transactionReference,
        'paidAt': paidAt,
        'message': message,
      };
}

// --- Review DTOs ---
class ReviewDto {
  final int id;
  final int serviceRequestId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String? comment;
  final String createdAt;

  ReviewDto({
    required this.id,
    required this.serviceRequestId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) => ReviewDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        customerId: json['customerId'] is int ? json['customerId'] : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        comment: json['comment'],
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'customerId': customerId,
        'technicianId': technicianId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };
}

class CreateReviewRequest {
  final int serviceRequestId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String? comment;

  CreateReviewRequest({
    required this.serviceRequestId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'customerId': customerId,
        'technicianId': technicianId,
        'rating': rating,
        'comment': comment,
      };
}

class UpdateReviewRequest {
  final int? rating;
  final String? comment;

  UpdateReviewRequest({this.rating, this.comment});

  Map<String, dynamic> toJson() => {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      };
}

// --- PromoCode & UserPromoCode DTOs ---
class PromoCodeDto {
  final int id;
  final String? code;
  final String? discountType;
  final double discountValue;
  final int? maxUses;
  final int usedCount;
  final String startDate;
  final String endDate;
  final bool isActive;

  PromoCodeDto({
    required this.id,
    this.code,
    this.discountType,
    required this.discountValue,
    this.maxUses,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory PromoCodeDto.fromJson(Map<String, dynamic> json) => PromoCodeDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        code: json['code'],
        discountType: json['discountType'],
        discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
        maxUses: json['maxUses'] as int?,
        usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'startDate': startDate,
        'endDate': endDate,
        'isActive': isActive,
      };
}

class CreatePromoCodeRequest {
  final String? code;
  final String? discountType;
  final double discountValue;
  final int? maxUses;
  final String startDate;
  final String endDate;

  CreatePromoCodeRequest({
    this.code,
    this.discountType,
    required this.discountValue,
    this.maxUses,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'maxUses': maxUses,
        'startDate': startDate,
        'endDate': endDate,
      };
}

class UpdatePromoCodeRequest {
  final String? code;
  final String? discountType;
  final double? discountValue;
  final int? maxUses;
  final String? startDate;
  final String? endDate;
  final bool? isActive;

  UpdatePromoCodeRequest({
    this.code,
    this.discountType,
    this.discountValue,
    this.maxUses,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (code != null) 'code': code,
        if (discountType != null) 'discountType': discountType,
        if (discountValue != null) 'discountValue': discountValue,
        if (maxUses != null) 'maxUses': maxUses,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (isActive != null) 'isActive': isActive,
      };
}

class UserPromoCodeDto {
  final int id;
  final int userId;
  final int promoCodeId;
  final int serviceRequestId;
  final double discountAmount;
  final String usedAt;

  UserPromoCodeDto({
    required this.id,
    required this.userId,
    required this.promoCodeId,
    required this.serviceRequestId,
    required this.discountAmount,
    required this.usedAt,
  });

  factory UserPromoCodeDto.fromJson(Map<String, dynamic> json) => UserPromoCodeDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
        promoCodeId: json['promoCodeId'] is int ? json['promoCodeId'] : int.tryParse(json['promoCodeId']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        usedAt: json['usedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'promoCodeId': promoCodeId,
        'serviceRequestId': serviceRequestId,
        'discountAmount': discountAmount,
        'usedAt': usedAt,
      };
}

class CreateUserPromoCodeRequest {
  final int userId;
  final int promoCodeId;
  final int serviceRequestId;
  final double discountAmount;

  CreateUserPromoCodeRequest({
    required this.userId,
    required this.promoCodeId,
    required this.serviceRequestId,
    required this.discountAmount,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'promoCodeId': promoCodeId,
        'serviceRequestId': serviceRequestId,
        'discountAmount': discountAmount,
      };
}

// --- Technician Wallet, Transaction & Payout DTOs ---
class TechnicianWalletDto {
  final int id;
  final int technicianId;
  final double balance;
  final String updatedAt;

  TechnicianWalletDto({
    required this.id,
    required this.technicianId,
    required this.balance,
    required this.updatedAt,
  });

  factory TechnicianWalletDto.fromJson(Map<String, dynamic> json) => TechnicianWalletDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        updatedAt: json['updatedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'balance': balance,
        'updatedAt': updatedAt,
      };
}

class CreateTechnicianWalletRequest {
  final int technicianId;

  CreateTechnicianWalletRequest({required this.technicianId});

  Map<String, dynamic> toJson() => {'technicianId': technicianId};
}

class UpdateTechnicianWalletRequest {
  final double balance;

  UpdateTechnicianWalletRequest({required this.balance});

  Map<String, dynamic> toJson() => {'balance': balance};
}

class WalletTransactionDto {
  final int id;
  final int walletId;
  final int? serviceRequestId;
  final double amount;
  final String? transactionType;
  final String? description;
  final String createdAt;

  WalletTransactionDto({
    required this.id,
    required this.walletId,
    this.serviceRequestId,
    required this.amount,
    this.transactionType,
    this.description,
    required this.createdAt,
  });

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) => WalletTransactionDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        walletId: json['walletId'] is int ? json['walletId'] : int.tryParse(json['walletId']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? ''),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        transactionType: json['transactionType'],
        description: json['description'],
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'walletId': walletId,
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'transactionType': transactionType,
        'description': description,
        'createdAt': createdAt,
      };
}

class CreateWalletTransactionRequest {
  final int walletId;
  final int? serviceRequestId;
  final double amount;
  final String? transactionType;
  final String? description;

  CreateWalletTransactionRequest({
    required this.walletId,
    this.serviceRequestId,
    required this.amount,
    this.transactionType,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'walletId': walletId,
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'transactionType': transactionType,
        'description': description,
      };
}

class PayoutDto {
  final int id;
  final int technicianId;
  final double amount;
  final String? status;
  final String? paymentMethod;
  final String? transactionReference;
  final String requestedAt;
  final String? completedAt;

  PayoutDto({
    required this.id,
    required this.technicianId,
    required this.amount,
    this.status,
    this.paymentMethod,
    this.transactionReference,
    required this.requestedAt,
    this.completedAt,
  });

  factory PayoutDto.fromJson(Map<String, dynamic> json) => PayoutDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        status: json['status'],
        paymentMethod: json['paymentMethod'],
        transactionReference: json['transactionReference'],
        requestedAt: json['requestedAt'] ?? '',
        completedAt: json['completedAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'amount': amount,
        'status': status,
        'paymentMethod': paymentMethod,
        'transactionReference': transactionReference,
        'requestedAt': requestedAt,
        'completedAt': completedAt,
      };
}

class CreatePayoutRequest {
  final int technicianId;
  final double amount;
  final String? paymentMethod;

  CreatePayoutRequest({
    required this.technicianId,
    required this.amount,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      };
}

class UpdatePayoutRequest {
  final String? status;
  final String? transactionReference;
  final String? completedAt;

  UpdatePayoutRequest({
    this.status,
    this.transactionReference,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        'transactionReference': transactionReference,
        'completedAt': completedAt,
      };
}

// --- Technician Availability & Service Area & Document DTOs ---
class TechnicianAvailabilityDto {
  final int id;
  final int technicianId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TechnicianAvailabilityDto({
    required this.id,
    required this.technicianId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TechnicianAvailabilityDto.fromJson(Map<String, dynamic> json) => TechnicianAvailabilityDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        dayOfWeek: json['dayOfWeek'] is int ? json['dayOfWeek'] : int.tryParse(json['dayOfWeek']?.toString() ?? '0') ?? 0,
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        isAvailable: json['isAvailable'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isAvailable': isAvailable,
      };
}

class CreateTechnicianAvailabilityRequest {
  final int technicianId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  CreateTechnicianAvailabilityRequest({
    required this.technicianId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isAvailable': isAvailable,
      };
}

class UpdateTechnicianAvailabilityRequest {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  UpdateTechnicianAvailabilityRequest({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isAvailable': isAvailable,
      };
}

class TechnicianDocumentDto {
  final int id;
  final int technicianId;
  final String? documentType;
  final String? documentUrl;
  final String uploadedAt;
  final String? status;
  final String? rejectionReason;
  final String? reviewedAt;

  TechnicianDocumentDto({
    required this.id,
    required this.technicianId,
    this.documentType,
    this.documentUrl,
    required this.uploadedAt,
    this.status,
    this.rejectionReason,
    this.reviewedAt,
  });

  factory TechnicianDocumentDto.fromJson(Map<String, dynamic> json) => TechnicianDocumentDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        documentType: json['documentType'],
        documentUrl: json['documentUrl'],
        uploadedAt: json['uploadedAt'] ?? '',
        status: json['status'],
        rejectionReason: json['rejectionReason'],
        reviewedAt: json['reviewedAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'documentType': documentType,
        'documentUrl': documentUrl,
        'uploadedAt': uploadedAt,
        'status': status,
        'rejectionReason': rejectionReason,
        'reviewedAt': reviewedAt,
      };
}

class CreateTechnicianDocumentRequest {
  final int technicianId;
  final String? documentType;
  final String? documentUrl;

  CreateTechnicianDocumentRequest({
    required this.technicianId,
    this.documentType,
    this.documentUrl,
  });

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'documentType': documentType,
        'documentUrl': documentUrl,
      };
}

class UpdateTechnicianDocumentRequest {
  final String? status;
  final String? rejectionReason;
  final String? reviewedAt;

  UpdateTechnicianDocumentRequest({
    this.status,
    this.rejectionReason,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        'rejectionReason': rejectionReason,
        'reviewedAt': reviewedAt,
      };
}

class TechnicianServiceAreaDto {
  final int technicianId;
  final int cityId;
  final String createdAt;

  TechnicianServiceAreaDto({
    required this.technicianId,
    required this.cityId,
    required this.createdAt,
  });

  factory TechnicianServiceAreaDto.fromJson(Map<String, dynamic> json) => TechnicianServiceAreaDto(
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        cityId: json['cityId'] is int ? json['cityId'] : int.tryParse(json['cityId']?.toString() ?? '0') ?? 0,
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'cityId': cityId,
        'createdAt': createdAt,
      };
}

class CreateTechnicianServiceAreaRequest {
  final int technicianId;
  final int cityId;

  CreateTechnicianServiceAreaRequest({
    required this.technicianId,
    required this.cityId,
  });

  Map<String, dynamic> toJson() => {
        'technicianId': technicianId,
        'cityId': cityId,
      };
}

// --- Conversations & Messages DTOs ---
class ConversationDto {
  final int id;
  final int serviceRequestId;
  final int customerId;
  final int technicianId;
  final String createdAt;

  ConversationDto({
    required this.id,
    required this.serviceRequestId,
    required this.customerId,
    required this.technicianId,
    required this.createdAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) => ConversationDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? '0') ?? 0,
        customerId: json['customerId'] is int ? json['customerId'] : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
        technicianId: json['technicianId'] is int ? json['technicianId'] : int.tryParse(json['technicianId']?.toString() ?? '0') ?? 0,
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceRequestId': serviceRequestId,
        'customerId': customerId,
        'technicianId': technicianId,
        'createdAt': createdAt,
      };
}

class CreateConversationRequest {
  final int serviceRequestId;
  final int customerId;
  final int technicianId;

  CreateConversationRequest({
    required this.serviceRequestId,
    required this.customerId,
    required this.technicianId,
  });

  Map<String, dynamic> toJson() => {
        'serviceRequestId': serviceRequestId,
        'customerId': customerId,
        'technicianId': technicianId,
      };
}

class MessageDto {
  final int id;
  final int conversationId;
  final int senderId;
  final String? messageText;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isRead;
  final String sentAt;

  MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.messageText,
    this.attachmentUrl,
    this.attachmentType,
    required this.isRead,
    required this.sentAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        conversationId: json['conversationId'] is int ? json['conversationId'] : int.tryParse(json['conversationId']?.toString() ?? '0') ?? 0,
        senderId: json['senderId'] is int ? json['senderId'] : int.tryParse(json['senderId']?.toString() ?? '0') ?? 0,
        messageText: json['messageText'],
        attachmentUrl: json['attachmentUrl'],
        attachmentType: json['attachmentType'],
        isRead: json['isRead'] ?? false,
        sentAt: json['sentAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'messageText': messageText,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'isRead': isRead,
        'sentAt': sentAt,
      };
}

class CreateMessageRequest {
  final int conversationId;
  final int senderId;
  final String? messageText;
  final String? attachmentUrl;
  final String? attachmentType;

  CreateMessageRequest({
    required this.conversationId,
    required this.senderId,
    this.messageText,
    this.attachmentUrl,
    this.attachmentType,
  });

  Map<String, dynamic> toJson() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'messageText': messageText,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      };
}

// --- Notifications DTOs ---
class NotificationDto {
  final int id;
  final int userId;
  final String? title;
  final String? message;
  final bool isRead;
  final String createdAt;
  final String? type;

  NotificationDto({
    required this.id,
    required this.userId,
    this.title,
    this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
        title: json['title'],
        message: json['message'],
        isRead: json['isRead'] ?? false,
        createdAt: json['createdAt'] ?? '',
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt,
        'type': type,
      };
}

class CreateNotificationRequest {
  final int userId;
  final String? title;
  final String? message;
  final String? type;

  CreateNotificationRequest({
    required this.userId,
    this.title,
    this.message,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
      };
}

class UpdateNotificationRequest {
  final bool isRead;

  UpdateNotificationRequest({required this.isRead});

  Map<String, dynamic> toJson() => {'isRead': isRead};
}

// --- Support Tickets & Messages DTOs ---
class SupportTicketDto {
  final int id;
  final int userId;
  final int? serviceRequestId;
  final String? subject;
  final String? description;
  final String? status;
  final String? priority;
  final String createdAt;
  final String? updatedAt;

  SupportTicketDto({
    required this.id,
    required this.userId,
    this.serviceRequestId,
    this.subject,
    this.description,
    this.status,
    this.priority,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketDto.fromJson(Map<String, dynamic> json) => SupportTicketDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
        serviceRequestId: json['serviceRequestId'] is int ? json['serviceRequestId'] : int.tryParse(json['serviceRequestId']?.toString() ?? ''),
        subject: json['subject'],
        description: json['description'],
        status: json['status'],
        priority: json['priority'],
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'serviceRequestId': serviceRequestId,
        'subject': subject,
        'description': description,
        'status': status,
        'priority': priority,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CreateSupportTicketRequest {
  final int userId;
  final int? serviceRequestId;
  final String? subject;
  final String? description;
  final String? priority;

  CreateSupportTicketRequest({
    required this.userId,
    this.serviceRequestId,
    this.subject,
    this.description,
    this.priority,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'serviceRequestId': serviceRequestId,
        'subject': subject,
        'description': description,
        'priority': priority,
      };
}

class UpdateSupportTicketRequest {
  final String? description;
  final String? status;
  final String? priority;

  UpdateSupportTicketRequest({
    this.description,
    this.status,
    this.priority,
  });

  Map<String, dynamic> toJson() => {
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
      };
}

class SupportMessageDto {
  final int id;
  final int supportTicketId;
  final int senderId;
  final String? message;
  final String? attachmentUrl;
  final String createdAt;

  SupportMessageDto({
    required this.id,
    required this.supportTicketId,
    required this.senderId,
    this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory SupportMessageDto.fromJson(Map<String, dynamic> json) => SupportMessageDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        supportTicketId: json['supportTicketId'] is int ? json['supportTicketId'] : int.tryParse(json['supportTicketId']?.toString() ?? '0') ?? 0,
        senderId: json['senderId'] is int ? json['senderId'] : int.tryParse(json['senderId']?.toString() ?? '0') ?? 0,
        message: json['message'],
        attachmentUrl: json['attachmentUrl'],
        createdAt: json['createdAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'supportTicketId': supportTicketId,
        'senderId': senderId,
        'message': message,
        'attachmentUrl': attachmentUrl,
        'createdAt': createdAt,
      };
}

class CreateSupportMessageRequest {
  final int supportTicketId;
  final int senderId;
  final String? message;
  final String? attachmentUrl;

  CreateSupportMessageRequest({
    required this.supportTicketId,
    required this.senderId,
    this.message,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() => {
        'supportTicketId': supportTicketId,
        'senderId': senderId,
        'message': message,
        'attachmentUrl': attachmentUrl,
      };
}
