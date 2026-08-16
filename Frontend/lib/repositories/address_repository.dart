import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IAddressRepository {
  Future<AddressDto> getAddressById(int id);
  Future<List<AddressDto>> getAddressesByCustomerId(int customerId);
  Future<AddressDto> createAddress(CreateAddressRequest request);
  Future<AddressDto> updateAddress(int id, UpdateAddressRequest request);
  Future<void> deleteAddress(int id);
}

class AddressRepository implements IAddressRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<AddressDto> getAddressById(int id) async {
    final response = await _client.get(ApiConstants.addressById(id));
    return AddressDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<AddressDto>> getAddressesByCustomerId(int customerId) async {
    final response = await _client.get(ApiConstants.addressesByCustomer(customerId));
    if (response is List) {
      return response.map((item) => AddressDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<AddressDto> createAddress(CreateAddressRequest request) async {
    final response = await _client.post(ApiConstants.addresses, body: request.toJson());
    return AddressDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AddressDto> updateAddress(int id, UpdateAddressRequest request) async {
    final response = await _client.put(ApiConstants.addressById(id), body: request.toJson());
    return AddressDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _client.delete(ApiConstants.addressById(id));
  }
}
