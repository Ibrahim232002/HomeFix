import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/technician_profile_model.dart';

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
  Future<List<TechnicianAvailabilityDto>> getAvailabilities(int technicianId);
  Future<TechnicianAvailabilityDto> createAvailability(CreateTechnicianAvailabilityRequest request);
  Future<TechnicianAvailabilityDto> updateAvailabilitySlot(int id, UpdateTechnicianAvailabilityRequest request);
  Future<List<TechnicianDocumentDto>> getDocuments(int technicianId);
  Future<TechnicianDocumentDto> uploadDocument(CreateTechnicianDocumentRequest request);
  Future<TechnicianDocumentDto> updateDocument(int id, UpdateTechnicianDocumentRequest request);
  Future<List<TechnicianServiceAreaDto>> getServiceAreas(int technicianId);
  Future<TechnicianServiceAreaDto> addServiceArea(CreateTechnicianServiceAreaRequest request);
  Future<void> deleteServiceArea(int technicianId, int cityId);
}

class TechnicianRepository implements ITechnicianRepository {
  final ApiClient _client = ApiClient();

  TechnicianProfileModel _mapProfile(TechnicianProfileDto dto) => TechnicianProfileModel(
        id: dto.id.toString(),
        userId: dto.userId.toString(),
        fullName: 'فني #${dto.id}',
        phoneNumber: '',
        bio: dto.bio ?? '',
        avatarUrl: dto.profileImageUrl ?? '',
        rating: dto.averageRating,
        reviewCount: dto.totalJobs,
        completedJobsCount: dto.totalJobs,
        experienceYears: dto.yearsOfExperience ?? 0,
        verified: dto.isVerified,
        isAvailable: dto.isAvailable,
        specialties: const [],
        primaryCategory: '',
        governorates: const [],
        cities: const [],
        workingDays: const [],
        workingHours: WorkingHoursModel(start: '08:00', end: '20:00'),
      );

  @override
  Future<List<TechnicianProfileModel>> getTechnicians() async {
    final active = await getApiActiveTechnicians();
    return active.map(_mapProfile).toList();
  }

  @override
  Future<TechnicianProfileModel?> getTechnicianById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    return _mapProfile(await getApiTechnicianProfileById(intId));
  }

  @override
  Future<TechnicianProfileModel?> getTechnicianByUserId(String userId) async {
    final intId = int.tryParse(userId);
    if (intId == null) return null;
    return _mapProfile(await getApiTechnicianProfileByUserId(intId));
  }

  @override
  Future<List<TechnicianProfileModel>> getTechniciansByService(String serviceId) async {
    final list = await getTechnicians();
    return list.where((t) => t.specialties.contains(serviceId) || t.primaryCategory == serviceId).toList();
  }

  @override
  Future<void> updateAvailability(String technicianId, bool isAvailable) async {
    final intId = int.tryParse(technicianId);
    if (intId == null) throw ArgumentError('معرف الفني غير صالح');
    await updateApiTechnicianProfile(
      intId,
      UpdateTechnicianProfileRequest(isAvailable: isAvailable),
    );
  }

  @override
  Future<void> toggleOnlineStatus(String technicianId) async {
    final tech = await getTechnicianById(technicianId);
    if (tech == null) throw StateError('Technician profile not found');
    await updateAvailability(technicianId, !tech.isAvailable);
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
    if (response is! List) return [];
    return response.map((item) => TechnicianProfileDto.fromJson(item as Map<String, dynamic>)).toList();
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
  Future<List<TechnicianAvailabilityDto>> getAvailabilities(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianAvailabilitiesByTechnician(technicianId));
    if (response is! List) return [];
    return response.map((item) => TechnicianAvailabilityDto.fromJson(item as Map<String, dynamic>)).toList();
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
    if (response is! List) return [];
    return response.map((item) => TechnicianDocumentDto.fromJson(item as Map<String, dynamic>)).toList();
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
  Future<List<TechnicianServiceAreaDto>> getServiceAreas(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianServiceAreasByTechnician(technicianId));
    if (response is! List) return [];
    return response.map((item) => TechnicianServiceAreaDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<TechnicianServiceAreaDto> addServiceArea(CreateTechnicianServiceAreaRequest request) async {
    final response = await _client.post(ApiConstants.technicianServiceAreas, body: request.toJson());
    return TechnicianServiceAreaDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteServiceArea(int technicianId, int cityId) async {
    await _client.delete(ApiConstants.deleteTechnicianServiceArea(technicianId, cityId));
  }
}
