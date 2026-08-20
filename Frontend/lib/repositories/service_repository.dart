import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/service_model.dart';

abstract class IServiceRepository {
  Future<List<ServiceModel>> getServices();
  Future<ServiceModel?> getServiceById(String id);
  Future<List<ServiceModel>> getServicesByCategory(
    String categoryId, {
    String categoryNameAr = '',
  });
  Future<List<ServiceModel>> searchServices(String query);

  // Direct OpenAPI DTO methods
  Future<List<ServiceDto>> getApiServices();
  Future<ServiceDto> getApiServiceById(int id);
  Future<ServicePricingDto?> getServicePricing({int? serviceId, int? cityId});
  Future<List<ServicePricingDto>> getServicePricingsByService(int serviceId);
}

class ServiceRepository implements IServiceRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<ServiceModel>> getServices() async {
    final apiServices = await getApiServices();
    final list = <ServiceModel>[];
    for (final dto in apiServices) {
      final pricings = await getServicePricingsByService(dto.id);
      list.add(_mapService(dto, pricings));
    }
    return list;
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;

    try {
      final dto = await getApiServiceById(intId);
      final pricings = await getServicePricingsByService(dto.id);
      return _mapService(dto, pricings);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(
    String categoryId, {
    String categoryNameAr = '',
  }) async {
    final parsedCategoryId = int.tryParse(categoryId);
    if (parsedCategoryId == null) return [];

    final response = await _client.get(
      ApiConstants.servicesByCategory(parsedCategoryId),
      includeAuth: false,
    );
    if (response is! List) return [];

    final services = <ServiceModel>[];
    for (final item in response) {
      final dto = ServiceDto.fromJson(item as Map<String, dynamic>);
      final pricings = await getServicePricingsByService(dto.id);
      services.add(
        _mapService(
          dto,
          pricings,
          categoryNameAr: categoryNameAr,
        ),
      );
    }

    return services;
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    final all = await getServices();
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return all
        .where((s) =>
            s.nameAr.toLowerCase().contains(q) ||
            s.nameEn.toLowerCase().contains(q) ||
            s.descriptionAr.toLowerCase().contains(q) ||
            s.categoryNameAr.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ServiceDto>> getApiServices() async {
    // ignore: avoid_print
    print('=== HOMEFIX GET /api/Services ===');
    try {
      final response = await _client.get(ApiConstants.services, includeAuth: false);
      if (response is List) {
        final list = response
            .map((item) => ServiceDto.fromJson(item as Map<String, dynamic>))
            .toList();
        // ignore: avoid_print
        print('=== API STATUS: SUCCESS ===');
        // ignore: avoid_print
        print('=== API SERVICES COUNT: ${list.length} ===');
        return list;
      }
      // ignore: avoid_print
      print('=== API STATUS: SUCCESS (NOT LIST) ===');
      // ignore: avoid_print
      print('=== API SERVICES COUNT: 0 ===');
    } catch (e) {
      // ignore: avoid_print
      print('=== API STATUS: ERROR ($e) ===');
      // ignore: avoid_print
      print('=== API SERVICES COUNT: 0 ===');
      rethrow;
    }
    return [];
  }

  @override
  Future<ServiceDto> getApiServiceById(int id) async {
    final response = await _client.get(
      ApiConstants.serviceById(id),
      includeAuth: false,
    );
    return ServiceDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ServicePricingDto?> getServicePricing({int? serviceId, int? cityId}) async {
    final queryParams = <String, dynamic>{};
    if (serviceId != null) queryParams['serviceId'] = serviceId;
    if (cityId != null) queryParams['cityId'] = cityId;

    final response = await _client.get(
      ApiConstants.servicePricings,
      queryParameters: queryParams,
      includeAuth: false,
    );
    if (response is Map<String, dynamic>) {
      return ServicePricingDto.fromJson(response);
    }
    return null;
  }

  @override
  Future<List<ServicePricingDto>> getServicePricingsByService(int serviceId) async {
    final response = await _client.get(
      ApiConstants.servicePricingsByService(serviceId),
      includeAuth: false,
    );
    if (response is List) {
      return response
          .map((item) => ServicePricingDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  ServiceModel _mapService(
    ServiceDto dto,
    List<ServicePricingDto> pricings, {
    String categoryNameAr = '',
  }) {
    final visitFee = pricings.isNotEmpty ? pricings.first.visitFee : 0.0;
    final minPrice = pricings.isNotEmpty && pricings.first.minimumPrice != null
        ? pricings.first.minimumPrice!
        : visitFee;

    return ServiceModel(
      id: dto.id.toString(),
      categoryId: dto.categoryId.toString(),
      categoryNameAr: categoryNameAr,
      nameAr: dto.name ?? '',
      nameEn: dto.name ?? '',
      descriptionAr: dto.description ?? '',
      descriptionEn: dto.description ?? '',
      pricing: ServicePricingModel(
        minPrice: minPrice,
        maxPrice: minPrice,
        visitFee: visitFee,
        currency: 'ج.م',
        unit: pricings.isNotEmpty ? 'لكل زيارة' : '',
      ),
      rating: 0.0,
      reviewCount: 0,
      estimatedDuration: '',
      iconName: 'Wrench',
      image: '',
      features: const [],
      isPopular: false,
    );
  }
}
