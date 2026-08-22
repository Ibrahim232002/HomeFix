import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/inspection_model.dart';

abstract class IInspectionRepository {
  Future<InspectionModel> createInspection({required int serviceRequestId, required DateTime scheduledAt});
  Future<InspectionModel?> getInspection(int id);
  Future<InspectionModel?> getInspectionByRequest(int serviceRequestId);
  Future<List<InspectionModel>> getMyInspections();
  Future<InspectionModel> scheduleInspection(int id, DateTime scheduledAt);
  Future<InspectionModel> startInspection(int id);
  Future<InspectionModel> completeInspection(int id, String findings);
  Future<InspectionModel> cancelInspection(int id);
  Future<InspectionModel> noShowInspection(int id);
}

class InspectionRepository implements IInspectionRepository {
  final ApiClient _client = ApiClient();

  InspectionModel _map(dynamic response) => InspectionModel.fromDto(
        InspectionDto.fromJson(response as Map<String, dynamic>),
      );

  @override
  Future<InspectionModel> createInspection({required int serviceRequestId, required DateTime scheduledAt}) async {
    final response = await _client.post(
      ApiConstants.inspections,
      body: {
        'serviceRequestId': serviceRequestId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      },
    );
    return _map(response);
  }

  @override
  Future<InspectionModel?> getInspection(int id) async {
    try {
      final response = await _client.get(ApiConstants.inspectionById(id));
      return _map(response);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<InspectionModel?> getInspectionByRequest(int serviceRequestId) async {
    try {
      final response = await _client.get(ApiConstants.inspectionByRequest(serviceRequestId));
      return _map(response);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<InspectionModel>> getMyInspections() async {
    final response = await _client.get(ApiConstants.myInspections);
    if (response is! List) return [];
    return response
        .whereType<Map<String, dynamic>>()
        .map(_map)
        .toList();
  }

  @override
  Future<InspectionModel> scheduleInspection(int id, DateTime scheduledAt) async {
    final response = await _client.post(
      ApiConstants.scheduleInspection(id),
      body: {'scheduledAt': scheduledAt.toUtc().toIso8601String()},
    );
    return _map(response);
  }

  @override
  Future<InspectionModel> startInspection(int id) async {
    final response = await _client.post(ApiConstants.startInspection(id), body: {});
    return _map(response);
  }

  @override
  Future<InspectionModel> completeInspection(int id, String findings) async {
    final response = await _client.post(
      ApiConstants.completeInspection(id),
      body: {'findings': findings},
    );
    return _map(response);
  }

  @override
  Future<InspectionModel> cancelInspection(int id) async {
    final response = await _client.post(ApiConstants.cancelInspection(id), body: {});
    return _map(response);
  }

  @override
  Future<InspectionModel> noShowInspection(int id) async {
    final response = await _client.post(ApiConstants.noShowInspection(id), body: {});
    return _map(response);
  }
}
