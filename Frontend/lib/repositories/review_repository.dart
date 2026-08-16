import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IReviewRepository {
  Future<ReviewDto> getReviewById(int id);
  Future<ReviewDto> getReviewByRequest(int serviceRequestId);
  Future<List<ReviewDto>> getReviewsByTechnician(int technicianId);
  Future<ReviewDto> createReview(CreateReviewRequest request);
  Future<ReviewDto> updateReview(int id, UpdateReviewRequest request);
}

class ReviewRepository implements IReviewRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<ReviewDto> getReviewById(int id) async {
    final response = await _client.get(ApiConstants.reviewById(id));
    return ReviewDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReviewDto> getReviewByRequest(int serviceRequestId) async {
    final response = await _client.get(ApiConstants.reviewByRequest(serviceRequestId));
    return ReviewDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<ReviewDto>> getReviewsByTechnician(int technicianId) async {
    final response = await _client.get(ApiConstants.reviewsByTechnician(technicianId));
    if (response is List) {
      return response.map((item) => ReviewDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ReviewDto> createReview(CreateReviewRequest request) async {
    final response = await _client.post(ApiConstants.reviews, body: request.toJson());
    return ReviewDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ReviewDto> updateReview(int id, UpdateReviewRequest request) async {
    final response = await _client.put(ApiConstants.reviewById(id), body: request.toJson());
    return ReviewDto.fromJson(response as Map<String, dynamic>);
  }
}
