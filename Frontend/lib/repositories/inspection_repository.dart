import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/inspection_dto.dart';
import '../models/inspection_model.dart';

class InspectionRepository {
  final ApiClient _client = ApiClient();

  Future<InspectionModel?> getById(String id) async {
    final value = int.tryParse(id);
    if (value == null || value <= 0) throw Exception('معرف الفحص غير صالح');
    final response = await _client.get(ApiConstants.inspectionById(value));
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  Future<InspectionModel?> getByRequest(String requestId) async {
    final value = int.tryParse(requestId);
    if (value == null || value <= 0) throw Exception('معرف الطلب غير صالح');
    try {
      final response = await _client.get(ApiConstants.inspectionByRequest(value));
      return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
    } catch (error) {
      if (error is ApiException && error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<InspectionModel>> getMine() async {
    final response = await _client.get(ApiConstants.myInspections);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((json) => _map(InspectionDto.fromJson(json)))
          .toList();
    }
    return [];
  }

  Future<InspectionModel> schedule(String id, DateTime scheduledAt) async {
    final response = await _client.put(ApiConstants.scheduleInspection(int.parse(id)), body: {
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    });
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  Future<InspectionModel> start(String id) async {
    final response = await _client.post(ApiConstants.startInspection(int.parse(id)), body: {});
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  Future<InspectionModel> complete(String id, {String? findings}) async {
    final response = await _client.post(ApiConstants.completeInspection(int.parse(id)), body: {
      if (findings != null && findings.trim().isNotEmpty) 'findings': findings.trim(),
    });
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  Future<InspectionModel> cancel(String id) async {
    final response = await _client.post(ApiConstants.cancelInspection(int.parse(id)), body: {});
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  Future<InspectionModel> noShow(String id) async {
    final response = await _client.post(ApiConstants.noShowInspection(int.parse(id)), body: {});
    return _map(InspectionDto.fromJson(response as Map<String, dynamic>));
  }

  InspectionModel _map(InspectionDto dto) {
    DateTime? parse(String value) => DateTime.tryParse(value);
    return InspectionModel(
      id: dto.id.toString(),
      serviceRequestId: dto.serviceRequestId.toString(),
      technicianId: dto.technicianId.toString(),
      fee: dto.fee,
      scheduledAt: parse(dto.scheduledAt) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: dto.status,
      findings: dto.findings,
      createdAt: parse(dto.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedAt: dto.completedAt == null ? null : parse(dto.completedAt!),
    );
  }
}
