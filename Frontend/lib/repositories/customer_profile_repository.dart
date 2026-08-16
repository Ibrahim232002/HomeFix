import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class ICustomerProfileRepository {
  Future<CustomerProfileDto> getProfileById(int id);
  Future<CustomerProfileDto> getProfileByUserId(int userId);
  Future<CustomerProfileDto> createProfile(CreateCustomerProfileRequest request);
  Future<CustomerProfileDto> updateProfile(int id, UpdateCustomerProfileRequest request);
}

class CustomerProfileRepository implements ICustomerProfileRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<CustomerProfileDto> getProfileById(int id) async {
    final response = await _client.get(ApiConstants.customerProfileById(id));
    return CustomerProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<CustomerProfileDto> getProfileByUserId(int userId) async {
    final response = await _client.get(ApiConstants.customerProfileByUser(userId));
    return CustomerProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<CustomerProfileDto> createProfile(CreateCustomerProfileRequest request) async {
    final response = await _client.post(ApiConstants.customerProfiles, body: request.toJson());
    return CustomerProfileDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<CustomerProfileDto> updateProfile(int id, UpdateCustomerProfileRequest request) async {
    final response = await _client.put(ApiConstants.customerProfileById(id), body: request.toJson());
    return CustomerProfileDto.fromJson(response as Map<String, dynamic>);
  }
}
