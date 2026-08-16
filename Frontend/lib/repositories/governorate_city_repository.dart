import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class IGovernorateCityRepository {
  Future<List<GovernorateDto>> getGovernorates();
  Future<GovernorateDto> getGovernorateById(int id);
  Future<List<CityDto>> getCities();
  Future<CityDto> getCityById(int id);
  Future<List<CityDto>> getCitiesByGovernorate(int governorateId);
}

class GovernorateCityRepository implements IGovernorateCityRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<GovernorateDto>> getGovernorates() async {
    final response = await _client.get(ApiConstants.governorates, includeAuth: false);
    if (response is List) {
      return response.map((item) => GovernorateDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<GovernorateDto> getGovernorateById(int id) async {
    final response = await _client.get(ApiConstants.governorateById(id), includeAuth: false);
    return GovernorateDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<CityDto>> getCities() async {
    final response = await _client.get(ApiConstants.cities, includeAuth: false);
    if (response is List) {
      return response.map((item) => CityDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<CityDto> getCityById(int id) async {
    final response = await _client.get(ApiConstants.cityById(id), includeAuth: false);
    return CityDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<CityDto>> getCitiesByGovernorate(int governorateId) async {
    final response = await _client.get(ApiConstants.citiesByGovernorate(governorateId), includeAuth: false);
    if (response is List) {
      return response.map((item) => CityDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
