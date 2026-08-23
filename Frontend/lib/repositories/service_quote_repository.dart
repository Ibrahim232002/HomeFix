import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/service_quote_model.dart';

abstract class IServiceQuoteRepository {
  Future<ServiceQuoteModel?> getQuote(int id);
  Future<List<ServiceQuoteModel>> getQuotesByInspection(int inspectionId);
  Future<ServiceQuoteModel> createQuote({required int inspectionId, required double amount, String? notes, DateTime? expiresAt});
  Future<ServiceQuoteModel> createRevision({required int quoteId, required double amount, String? notes, DateTime? expiresAt});
  Future<void> acceptQuote(int id);
  Future<void> rejectQuote(int id);
}

class ServiceQuoteRepository implements IServiceQuoteRepository {
  final ApiClient _client = ApiClient();

  ServiceQuoteModel _map(dynamic response) => ServiceQuoteModel.fromDto(
        ServiceQuoteDto.fromJson(response as Map<String, dynamic>),
      );

  @override
  Future<ServiceQuoteModel?> getQuote(int id) async {
    final response = await _client.get(ApiConstants.serviceQuoteById(id));
    return _map(response);
  }

  @override
  Future<List<ServiceQuoteModel>> getQuotesByInspection(int inspectionId) async {
    final response = await _client.get(ApiConstants.serviceQuotesByInspection(inspectionId));
    if (response is! List) return [];
    return response
        .whereType<Map<String, dynamic>>()
        .map(_map)
        .toList();
  }

  Map<String, dynamic> _requestBody({int? inspectionId, required double amount, String? notes, DateTime? expiresAt}) => {
        if (inspectionId != null) 'inspectionId': inspectionId,
        'amount': amount,
        'notes': notes,
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
      };

  @override
  Future<ServiceQuoteModel> createQuote({required int inspectionId, required double amount, String? notes, DateTime? expiresAt}) async {
    final response = await _client.post(
      ApiConstants.serviceQuotes,
      body: _requestBody(inspectionId: inspectionId, amount: amount, notes: notes, expiresAt: expiresAt),
    );
    return _map(response);
  }

  @override
  Future<ServiceQuoteModel> createRevision({required int quoteId, required double amount, String? notes, DateTime? expiresAt}) async {
    final response = await _client.post(
      ApiConstants.serviceQuoteRevision(quoteId),
      body: _requestBody(amount: amount, notes: notes, expiresAt: expiresAt),
    );
    return _map(response);
  }

  @override
  Future<void> acceptQuote(int id) async {
    await _client.post(ApiConstants.acceptServiceQuote(id), body: {});
  }

  @override
  Future<void> rejectQuote(int id) async {
    await _client.post(ApiConstants.rejectServiceQuote(id), body: {});
  }
}
