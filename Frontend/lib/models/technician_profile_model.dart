class WorkingHoursModel {
  final String start;
  final String end;

  WorkingHoursModel({required this.start, required this.end});

  Map<String, dynamic> toJson() => {'start': start, 'end': end};

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) =>
      WorkingHoursModel(
        start: json['start'] ?? '08:00',
        end: json['end'] ?? '20:00',
      );
}

class TechnicianProfileModel {
  final String userId;
  final String id;
  final String fullName;
  final String avatarUrl;
  final String bio;
  final double rating;
  final int reviewCount;
  final int completedJobsCount;
  final bool isAvailable;
  final List<String> specialties;
  final String primaryCategory;
  final List<String> governorates;
  final List<String> cities;
  final double? hourlyRate;
  final int experienceYears;
  final bool verified;
  final List<String> workingDays;
  final WorkingHoursModel workingHours;
  final String phoneNumber;
  final double? currentLatitude;
  final double? currentLongitude;
  final int? currentGovernorateId;
  final int? currentCityId;

  TechnicianProfileModel({
    required this.userId,
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.completedJobsCount,
    required this.isAvailable,
    required this.specialties,
    required this.primaryCategory,
    required this.governorates,
    required this.cities,
    this.hourlyRate,
    required this.experienceYears,
    required this.verified,
    required this.workingDays,
    required this.workingHours,
    required this.phoneNumber,
    this.currentLatitude,
    this.currentLongitude,
    this.currentGovernorateId,
    this.currentCityId,
  });

  TechnicianProfileModel copyWith({
    String? userId,
    String? id,
    String? fullName,
    String? avatarUrl,
    String? bio,
    double? rating,
    int? reviewCount,
    int? completedJobsCount,
    bool? isAvailable,
    List<String>? specialties,
    String? primaryCategory,
    List<String>? governorates,
    List<String>? cities,
    double? hourlyRate,
    int? experienceYears,
    bool? verified,
    List<String>? workingDays,
    WorkingHoursModel? workingHours,
    String? phoneNumber,
    double? currentLatitude,
    double? currentLongitude,
    int? currentGovernorateId,
    int? currentCityId,
  }) {
    return TechnicianProfileModel(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      isAvailable: isAvailable ?? this.isAvailable,
      specialties: specialties ?? this.specialties,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      governorates: governorates ?? this.governorates,
      cities: cities ?? this.cities,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      experienceYears: experienceYears ?? this.experienceYears,
      verified: verified ?? this.verified,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentGovernorateId: currentGovernorateId ?? this.currentGovernorateId,
      currentCityId: currentCityId ?? this.currentCityId,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'id': id,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'rating': rating,
        'reviewCount': reviewCount,
        'completedJobsCount': completedJobsCount,
        'isAvailable': isAvailable,
        'specialties': specialties,
        'primaryCategory': primaryCategory,
        'governorates': governorates,
        'cities': cities,
        'hourlyRate': hourlyRate,
        'experienceYears': experienceYears,
        'verified': verified,
        'workingDays': workingDays,
        'workingHours': workingHours.toJson(),
        'phoneNumber': phoneNumber,
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
        'currentGovernorateId': currentGovernorateId,
        'currentCityId': currentCityId,
      };

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) =>
      TechnicianProfileModel(
        userId: json['userId'] ?? '',
        id: json['id'] ?? '',
        fullName: json['fullName'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        bio: json['bio'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        completedJobsCount: (json['completedJobsCount'] as num?)?.toInt() ?? 0,
        isAvailable: json['isAvailable'] ?? true,
        specialties: (json['specialties'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        primaryCategory: json['primaryCategory'] ?? '',
        governorates: (json['governorates'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        cities: (json['cities'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
        experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 1,
        verified: json['verified'] ?? false,
        workingDays: (json['workingDays'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        workingHours: WorkingHoursModel.fromJson(json['workingHours'] ?? {}),
        phoneNumber: json['phoneNumber'] ?? '',
        currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
        currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
        currentGovernorateId: json['currentGovernorateId'] is int ? json['currentGovernorateId'] : int.tryParse(json['currentGovernorateId']?.toString() ?? ''),
        currentCityId: json['currentCityId'] is int ? json['currentCityId'] : int.tryParse(json['currentCityId']?.toString() ?? ''),
      );
}
