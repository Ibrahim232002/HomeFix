import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/offer_model.dart';

class ServiceRequestOfferRepository {
  final ApiClient _client = ApiClient();

  Future<List<ServiceRequestOfferModel>> getOffersForRequest(int requestId) async {
    final response = await _client.get(ApiConstants.serviceRequestOffersByRequest(requestId));
    if (response is List) {
      return response
          .map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<ServiceRequestOfferModel>> getMyOffers() async {
    final response = await _client.get(ApiConstants.myServiceRequestOffers);
    if (response is List) {
      return response
          .map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ServiceRequestOfferModel> createOffer({
    required int serviceRequestId,
    required double proposedPrice,
    String? technicianNote,
  }) async {
    final response = await _client.post(
      ApiConstants.serviceRequestOffers,
      body: {
        'serviceRequestId': serviceRequestId,
        'proposedPrice': proposedPrice,
        'technicianNote': technicianNote,
      },
    );
    return ServiceRequestOfferModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> acceptOffer(int offerId) async {
    await _client.post(ApiConstants.acceptServiceRequestOffer(offerId), body: {});
  }

  Future<void> rejectOffer(int offerId) async {
    await _client.post(ApiConstants.rejectServiceRequestOffer(offerId), body: {});
  }

  Future<List<ServiceRequestOfferModel>> getOffersForTechnician(int technicianId) async {
    final response = await _client.get(ApiConstants.serviceRequestOffersByTechnician(technicianId));
    if (response is List) {
      return response
          .map((item) => ServiceRequestOfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
