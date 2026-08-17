import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IPromoCodeRepository {
  Future<PromoCodeDto> getPromoCodeById(int id);
  Future<PromoCodeDto?> getPromoCodeByCode(String code);
  Future<List<PromoCodeDto>> getActivePromoCodes();
  Future<PromoCodeDto> createPromoCode(CreatePromoCodeRequest request);
  Future<PromoCodeDto> updatePromoCode(int id, UpdatePromoCodeRequest request);
  Future<UserPromoCodeDto> getUserPromoCodeById(int id);
  Future<List<UserPromoCodeDto>> getUserPromoCodesByUser(int userId);
  Future<UserPromoCodeDto> createUserPromoCode(CreateUserPromoCodeRequest request);
}

class PromoCodeRepository implements IPromoCodeRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<PromoCodeDto> getPromoCodeById(int id) async {
    final response = await _client.get(ApiConstants.promoCodeById(id));
    return PromoCodeDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PromoCodeDto?> getPromoCodeByCode(String code) async {
    try {
      final response = await _client.get(ApiConstants.promoCodeByCode(code));
      if (response is Map<String, dynamic>) return PromoCodeDto.fromJson(response);
    } catch (_) {}
    return null;
  }

  @override
  Future<List<PromoCodeDto>> getActivePromoCodes() async {
    final response = await _client.get(ApiConstants.activePromoCodes, includeAuth: false);
    if (response is List) return response.map((item) => PromoCodeDto.fromJson(item as Map<String, dynamic>)).toList();
    return [];
  }

  @override
  Future<PromoCodeDto> createPromoCode(CreatePromoCodeRequest request) async {
    final response = await _client.post(ApiConstants.promoCodes, body: request.toJson());
    return PromoCodeDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PromoCodeDto> updatePromoCode(int id, UpdatePromoCodeRequest request) async {
    final response = await _client.put(ApiConstants.promoCodeById(id), body: request.toJson());
    return PromoCodeDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserPromoCodeDto> getUserPromoCodeById(int id) async {
    final response = await _client.get(ApiConstants.userPromoCodeById(id));
    return UserPromoCodeDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<UserPromoCodeDto>> getUserPromoCodesByUser(int userId) async {
    throw UnsupportedError('The current backend does not expose a user-wide applied-promo listing endpoint. Use the service-request-specific endpoint.');
  }

  @override
  Future<UserPromoCodeDto> createUserPromoCode(CreateUserPromoCodeRequest request) async {
    final response = await _client.post(ApiConstants.userPromoCodes, body: request.toJson());
    return UserPromoCodeDto.fromJson(response as Map<String, dynamic>);
  }
}
