import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class ICityRepository {
  Future<List<CityDto>> getActiveCities();
}

class CityRepository implements ICityRepository {
  CityRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<CityDto>> getActiveCities() async {
    final response = await _client.get(ApiConstants.cities, includeAuth: false);
    if (response is! List) return [];

    return response
        .map((item) => CityDto.fromJson(item as Map<String, dynamic>))
        .where((city) => city.isActive)
        .toList();
  }
}
