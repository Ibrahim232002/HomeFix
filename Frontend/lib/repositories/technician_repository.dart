import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/technician_profile_model.dart';
import '../models/technician_service_area_model.dart';

abstract class ITechnicianRepository {
  Future<List<TechnicianProfileModel>> getTechnicians();
  Future<TechnicianProfileModel?> getTechnicianById(String id);
  Future<TechnicianProfileModel?> getTechnicianByUserId(String userId);
  Future<List<TechnicianProfileModel>> getTechniciansByService(String serviceId);
  Future<void> updateAvailability(String technicianId, bool isAvailable);
  Future<void> toggleOnlineStatus(String technicianId);
  Future<TechnicianProfileDto> getApiTechnicianProfileById(int id);
  Future<TechnicianProfileDto> getApiTechnicianProfileByUserId(int userId);
  Future<List<TechnicianProfileDto>> getApiActiveTechnicians();
  Future<TechnicianProfileDto> createApiTechnicianProfile(CreateTechnicianProfileRequest request);
  Future<TechnicianProfileDto> updateApiTechnicianProfile(int id, UpdateTechnicianProfileRequest request);
  Future<TechnicianProfileModel> updateTechnicianSpecialization(
    int technicianId, {
    required int categoryId,
    required List<int> serviceIds,
  });
  Future<TechnicianProfileModel> updateCurrentLocation({
    required int technicianId,
    int? currentGovernorateId,
    int? currentCityId,
    double? currentLatitude,
    double? currentLongitude,
  });
  Future<List<TechnicianAvailabilityDto>> getAvailabilities(int technicianId);
  Future<TechnicianAvailabilityDto> createAvailability(CreateTechnicianAvailabilityRequest request);
  Future<TechnicianAvailabilityDto> updateAvailabilitySlot(int id, UpdateTechnicianAvailabilityRequest request);
  Future<List<TechnicianDocumentDto>> getDocuments(int technicianId);
  Future<TechnicianDocumentDto> uploadDocument(CreateTechnicianDocumentRequest request);
  Future<TechnicianDocumentDto> updateDocument(int id, UpdateTechnicianDocumentRequest request);
  Future<List<TechnicianServiceAreaModel>> getServiceAreas(int technicianId);
  Future<TechnicianServiceAreaModel> addServiceArea(int technicianId, int cityId);
  Future<void> deleteServiceArea(int technicianId, int cityId);
}

class TechnicianRepository implements ITechnicianRepository {
  final ApiClient _client = ApiClient();

  TechnicianProfileModel _mapProfile(TechnicianProfileDto dto) => TechnicianProfileModel(
        id: dto.id.toString(), userId: dto.userId.toString(), fullName: 'فني #${dto.id}', phoneNumber: '', bio: dto.bio ?? '',
        avatarUrl: dto.profileImageUrl ?? '', rating: dto.averageRating, reviewCount: dto.totalJobs, completedJobsCount: dto.totalJobs,
        experienceYears: dto.yearsOfExperience ?? 0, verified: dto.isVerified, isAvailable: dto.isAvailable,
        specialties: const [], primaryCategory: '', governorates: const [], cities: const [], workingDays: const [],
        workingHours: WorkingHoursModel(start: '08:00', end: '20:00'), currentLatitude: dto.currentLatitude, currentLongitude: dto.currentLongitude,
        categoryId: dto.categoryId, categoryName: dto.categoryName, serviceIds: dto.serviceIds,
      );

  TechnicianProfileModel _mapProfileResponse(Map<String, dynamic> json) {
    final serviceIds = (json['serviceIds'] as List<dynamic>? ?? [])
        .map((value) => value is int ? value : int.tryParse(value.toString()))
        .whereType<int>()
        .toList();

    return TechnicianProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: 'فني #${json['id'] ?? ''}',
      phoneNumber: '',
      bio: json['bio']?.toString() ?? '',
      avatarUrl: json['profileImageUrl']?.toString() ?? '',
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['totalJobs'] as num?)?.toInt() ?? 0,
      completedJobsCount: (json['totalJobs'] as num?)?.toInt() ?? 0,
      experienceYears: (json['yearsOfExperience'] as num?)?.toInt() ?? 0,
      verified: json['isVerified'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      specialties: const [],
      primaryCategory: '',
      governorates: const [],
      cities: const [],
      workingDays: const [],
      workingHours: WorkingHoursModel(start: '08:00', end: '20:00'),
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      currentGovernorateId: json['currentGovernorateId'] is int ? json['currentGovernorateId'] : int.tryParse(json['currentGovernorateId']?.toString() ?? ''),
      currentCityId: json['currentCityId'] is int ? json['currentCityId'] : int.tryParse(json['currentCityId']?.toString() ?? ''),
      categoryId: json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId']?.toString() ?? ''),
      categoryName: json['categoryName']?.toString(),
      serviceIds: serviceIds,
    );
  }

  @override
  Future<List<TechnicianProfileModel>> getTechnicians() async {
    final active = await getApiActiveTechnicians();
    return active.map(_mapProfile).toList();
  }

  @override
  Future<TechnicianProfileModel?> getTechnicianById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final response = await _client.get(ApiConstants.technicianProfileById(intId));
    return _mapProfileResponse(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianProfileModel?> getTechnicianByUserId(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId == null) return null;
    final response = await _client.get(ApiConstants.technicianProfileByUser(intUserId));
    return _mapProfileResponse(response as Map<String, dynamic>);
  }

  @override
  Future<List<TechnicianProfileModel>> getTechniciansByService(String serviceId) async {
    final list = await getTechnicians();
    return list.where((t) => t.specialties.contains(serviceId) || t.primaryCategory == serviceId).toList();
  }

  @override
  Future<void> updateAvailability(String technicianId, bool isAvailable) async {
    final id = int.tryParse(technicianId);
    if (id == null) throw Exception('معرف الفني غير صالح');
    await updateApiTechnicianProfile(id, UpdateTechnicianProfileRequest(isAvailable: isAvailable));
  }

  @override
  Future<void> toggleOnlineStatus(String technicianId) async {
    final tech = await getTechnicianById(technicianId);
    if (tech != null) await updateAvailability(technicianId, !tech.isAvailable);
  }

  @override
  Future<TechnicianProfileDto> getApiTechnicianProfileById(int id) async {
    final response = await _client.get(ApiConstants.technicianProfileById(id));
    return TechnicianProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianProfileDto> getApiTechnicianProfileByUserId(int userId) async {
    final response = await _client.get(ApiConstants.technicianProfileByUser(userId));
    return TechnicianProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<TechnicianProfileDto>> getApiActiveTechnicians() async {
    final response = await _client.get(ApiConstants.activeTechnicianProfiles, includeAuth: false);
    if (response is List) return response.map((item) => TechnicianProfileDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<TechnicianProfileDto> createApiTechnicianProfile(CreateTechnicianProfileRequest request) async {
    final response = await _client.post(ApiConstants.technicianProfiles, body: request.toJson());
    return TechnicianProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianProfileDto> updateApiTechnicianProfile(int id, UpdateTechnicianProfileRequest request) async {
    final response = await _client.put(ApiConstants.technicianProfileById(id), body: request.toJson());
    return TechnicianProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianProfileModel> updateTechnicianSpecialization(
    int technicianId, {
    required int categoryId,
    required List<int> serviceIds,
  }) async {
    final dto = await updateApiTechnicianProfile(
      technicianId,
      UpdateTechnicianProfileRequest(
        categoryId: categoryId,
        serviceIds: List<int>.from(serviceIds)..sort(),
      ),
    );
    return _mapProfile(dto);
  }

  @override
  Future<TechnicianProfileModel> updateCurrentLocation({
    required int technicianId,
    int? currentGovernorateId,
    int? currentCityId,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    final body = <String, dynamic>{
      'currentGovernorateId': currentGovernorateId,
      'currentCityId': currentCityId,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
    debugPrint('[TECH_CURRENT_LOCATION] PUT payload:');
    debugPrint('currentGovernorateId: $currentGovernorateId');
    debugPrint('currentCityId: $currentCityId');
    debugPrint('currentLatitude: $currentLatitude');
    debugPrint('currentLongitude: $currentLongitude');

    try {
      final response = await _client.put(
        ApiConstants.technicianProfileById(technicianId),
        body: body,
      );
      final responseMap = response as Map<String, dynamic>;
      debugPrint('[TECH_CURRENT_LOCATION] backend response: $responseMap');
      return _mapProfileResponse(responseMap);
    } catch (e) {
      debugPrint('[TECH_CURRENT_LOCATION] backend exception: $e');
      rethrow;
    }
  }

  @override
  Future<List<TechnicianAvailabilityDto>> getAvailabilities(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianAvailabilitiesByTechnician(technicianId));
    if (response is List) return response.map((item) => TechnicianAvailabilityDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<TechnicianAvailabilityDto> createAvailability(CreateTechnicianAvailabilityRequest request) async {
    final response = await _client.post(ApiConstants.technicianAvailabilities, body: request.toJson());
    return TechnicianAvailabilityDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianAvailabilityDto> updateAvailabilitySlot(int id, UpdateTechnicianAvailabilityRequest request) async {
    final response = await _client.put(ApiConstants.technicianAvailabilityById(id), body: request.toJson());
    return TechnicianAvailabilityDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<TechnicianDocumentDto>> getDocuments(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianDocumentsByTechnician(technicianId));
    if (response is List) return response.map((item) => TechnicianDocumentDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<TechnicianDocumentDto> uploadDocument(CreateTechnicianDocumentRequest request) async {
    final response = await _client.post(ApiConstants.technicianDocuments, body: request.toJson());
    return TechnicianDocumentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianDocumentDto> updateDocument(int id, UpdateTechnicianDocumentRequest request) async {
    final response = await _client.put(ApiConstants.technicianDocumentById(id), body: request.toJson());
    return TechnicianDocumentDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<TechnicianServiceAreaModel>> getServiceAreas(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianServiceAreasByTechnician(technicianId));
    if (response is List) return response.map((item) => TechnicianServiceAreaModel.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<TechnicianServiceAreaModel> addServiceArea(int technicianId, int cityId) async {
    final response = await _client.post(ApiConstants.technicianServiceAreas, body: {'technicianId': technicianId, 'cityId': cityId});
    return TechnicianServiceAreaModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteServiceArea(int technicianId, int cityId) async {
    await _client.delete(ApiConstants.deleteTechnicianServiceArea(technicianId, cityId));
  }
}
