import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/service_request_offer_model.dart';

class ServiceRequestOfferRepository {
  final ApiClient _client = ApiClient();

  Future<List<ServiceRequestOfferModel>> getByRequest(int requestId) async {
    final response = await _client.get('/api/ServiceRequestOffers/request/$requestId');
    if (response is! List) return [];
    return response
        .map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceRequestOfferModel>> getMine() async {
    final response = await _client.get('/api/ServiceRequestOffers/mine');
    if (response is! List) return [];
    return response
        .map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceRequestOfferModel> create({
    required int serviceRequestId,
    required double proposedPrice,
    String? technicianNote,
  }) async {
    if (proposedPrice <= 0) throw ArgumentError('السعر المقترح يجب أن يكون أكبر من صفر');
    final response = await _client.post(
      '/api/ServiceRequestOffers',
      body: {
        'serviceRequestId': serviceRequestId,
        'proposedPrice': proposedPrice,
        if (technicianNote != null && technicianNote.trim().isNotEmpty)
          'technicianNote': technicianNote.trim(),
      },
    );
    return ServiceRequestOfferModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> accept(int offerId) async {
    await _client.post('/api/ServiceRequestOffers/$offerId/accept');
  }

  Future<void> reject(int offerId) async {
    await _client.post('/api/ServiceRequestOffers/$offerId/reject');
  }
}
