class ServiceRequestApiDto {
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
  final String? serviceName;
  final String? serviceDescription;
  final String? serviceImageUrl;
  final int? estimatedDurationMinutes;
  final String? addressLabel;
  final String? fullAddress;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? additionalInstructions;
  final int? governorateId;
  final int? cityId;
  final String? governorateName;
  final String? cityName;

  const ServiceRequestApiDto({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.addressId,
    required this.description,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    required this.visitFee,
    required this.createdAt,
    required this.updatedAt,
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceImageUrl,
    required this.estimatedDurationMinutes,
    required this.addressLabel,
    required this.fullAddress,
    required this.buildingNumber,
    required this.floorNumber,
    required this.apartmentNumber,
    required this.additionalInstructions,
    required this.governorateId,
    required this.cityId,
    required this.governorateName,
    required this.cityName,
  });

  factory ServiceRequestApiDto.fromJson(Map<String, dynamic> json) => ServiceRequestApiDto(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        customerId: json['customerId'] is int ? json['customerId'] : int.tryParse(json['customerId']?.toString() ?? '0') ?? 0,
        serviceId: json['serviceId'] is int ? json['serviceId'] : int.tryParse(json['serviceId']?.toString() ?? '0') ?? 0,
        addressId: json['addressId'] is int ? json['addressId'] : int.tryParse(json['addressId']?.toString() ?? '0') ?? 0,
        description: json['description'],
        preferredDate: json['preferredDate']?.toString(),
        preferredTime: json['preferredTime']?.toString(),
        status: json['status']?.toString(),
        visitFee: (json['visitFee'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString(),
        serviceName: json['serviceName']?.toString(),
        serviceDescription: json['serviceDescription']?.toString(),
        serviceImageUrl: json['serviceImageUrl']?.toString(),
        estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt(),
        addressLabel: json['addressLabel']?.toString(),
        fullAddress: json['fullAddress']?.toString(),
        buildingNumber: json['buildingNumber']?.toString(),
        floorNumber: json['floorNumber']?.toString(),
        apartmentNumber: json['apartmentNumber']?.toString(),
        additionalInstructions: json['additionalInstructions']?.toString(),
        governorateId: (json['governorateId'] as num?)?.toInt(),
        cityId: (json['cityId'] as num?)?.toInt(),
        governorateName: json['governorateName']?.toString(),
        cityName: json['cityName']?.toString(),
      );
}