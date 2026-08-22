import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/service_quote_dto.dart';
import '../models/service_quote_model.dart';

class ServiceQuoteRepository {
  final ApiClient _client = ApiClient();

  Future<List<ServiceQuoteModel>> getByInspection(String inspectionId) async {
    final id = int.tryParse(inspectionId);
    if (id == null || id <= 0) throw Exception('معرف الفحص غير صالح');
    final response = await _client.get(ApiConstants.serviceQuotesByInspection(id));
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((json) => _map(ServiceQuoteDto.fromJson(json)))
          .toList();
    }
    return [];
  }

  Future<ServiceQuoteModel> create({required String inspectionId, required double amount, String? notes, DateTime? expiresAt}) async {
    final id = int.tryParse(inspectionId);
    if (id == null || id <= 0) throw Exception('معرف الفحص غير صالح');
    final response = await _client.post(ApiConstants.serviceQuotes, body: {
      'inspectionId': id,
      'amount': amount,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (expiresAt != null) 'expiresAt': expiresAt.toUtc().toIso8601String(),
    });
    return _map(ServiceQuoteDto.fromJson(response as Map<String, dynamic>));
  }

  Future<ServiceQuoteModel> createRevision({required String quoteId, required double amount, String? notes, DateTime? expiresAt}) async {
    final id = int.tryParse(quoteId);
    if (id == null || id <= 0) throw Exception('معرف العرض السعري غير صالح');
    final response = await _client.post(ApiConstants.createServiceQuoteRevision(id), body: {
      'amount': amount,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (expiresAt != null) 'expiresAt': expiresAt.toUtc().toIso8601String(),
    });
    return _map(ServiceQuoteDto.fromJson(response as Map<String, dynamic>));
  }

  Future<void> accept(String quoteId) async => _client.post(ApiConstants.acceptServiceQuote(int.parse(quoteId)), body: {});

  Future<void> reject(String quoteId) async => _client.post(ApiConstants.rejectServiceQuote(int.parse(quoteId)), body: {});

  ServiceQuoteModel _map(ServiceQuoteDto dto) {
    DateTime? parse(String? value) => value == null ? null : DateTime.tryParse(value);
    return ServiceQuoteModel(
      id: dto.id.toString(),
      inspectionId: dto.inspectionId.toString(),
      amount: dto.amount,
      status: dto.status,
      notes: dto.notes,
      revision: dto.revision,
      createdAt: parse(dto.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt: parse(dto.expiresAt),
    );
  }
}
