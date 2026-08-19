import '../core/network/api_client.dart';
import '../models/offer_model.dart';

class ServiceRequestOfferRepository {
  final ApiClient _client = ApiClient();

  Future<List<ServiceRequestOfferModel>> getOffersForRequest(int requestId) async {
    final response = await _client.get('/api/ServiceRequestOffers/request/$requestId');
    if (response is List) {
      return response.map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<ServiceRequestOfferModel>> getMyOffers() async {
    final response = await _client.get('/api/ServiceRequestOffers/mine');
    if (response is List) {
      return response.map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ServiceRequestOfferModel> createOffer({
    required int serviceRequestId,
    required double proposedPrice,
    String? technicianNote,
  }) async {
    final response = await _client.post(
      '/api/ServiceRequestOffers',
      body: {
        'serviceRequestId': serviceRequestId,
        'proposedPrice': proposedPrice,
        'technicianNote': technicianNote,
      },
    );
    return ServiceRequestOfferModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> acceptOffer(int offerId) async {
    await _client.post('/api/ServiceRequestOffers/$offerId/accept', body: {});
  }

  Future<void> rejectOffer(int offerId) async {
    await _client.post('/api/ServiceRequestOffers/$offerId/reject', body: {});
  }

  Future<List<ServiceRequestOfferModel>> getOffersForTechnician(int technicianId) async {
    final response = await _client.get('/api/ServiceRequestOffers/technician/$technicianId');
    if (response is List) {
      return response.map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
