import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/service_model.dart';

abstract class IServiceRepository {
  Future<List<ServiceModel>> getServices();
  Future<ServiceModel?> getServiceById(String id);
  Future<List<ServiceModel>> getServicesByCategory(String categoryId);
  Future<List<ServiceModel>> searchServices(String query);
  Future<List<ServiceDto>> getApiServices();
  Future<ServiceDto> getApiServiceById(int id);
  Future<ServicePricingDto?> getServicePricing({int? serviceId, int? cityId});
  Future<List<ServicePricingDto>> getServicePricingsByService(int serviceId);
}

class ServiceRepository implements IServiceRepository {
  final ApiClient _client = ApiClient();

  ServiceModel _mapService(ServiceDto dto, List<ServicePricingDto> pricings) {
    final visitFee = pricings.isNotEmpty ? pricings.first.visitFee : 0.0;
    final minPrice = pricings.isNotEmpty && pricings.first.minimumPrice != null
        ? pricings.first.minimumPrice!
        : visitFee;
    return ServiceModel(
      id: dto.id.toString(),
      categoryId: '',
      categoryNameAr: '',
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

  @override
  Future<List<ServiceModel>> getServices() async {
    final apiServices = await getApiServices();
    final result = <ServiceModel>[];
    for (final dto in apiServices) {
      final pricings = await getServicePricingsByService(dto.id);
      result.add(_mapService(dto, pricings));
    }
    return result;
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final dto = await getApiServiceById(intId);
    final pricings = await getServicePricingsByService(dto.id);
    return _mapService(dto, pricings);
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    final all = await getServices();
    if (categoryId.isEmpty || categoryId == 'all') return all;
    return all.where((service) => service.categoryId == categoryId).toList();
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    final all = await getServices();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((service) =>
            service.nameAr.toLowerCase().contains(q) ||
            service.nameEn.toLowerCase().contains(q) ||
            service.descriptionAr.toLowerCase().contains(q) ||
            service.categoryNameAr.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ServiceDto>> getApiServices() async {
    final response = await _client.get(ApiConstants.services, includeAuth: false);
    if (response is! List) return [];
    return response.map((item) => ServiceDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceDto> getApiServiceById(int id) async {
    final response = await _client.get(ApiConstants.serviceById(id), includeAuth: false);
    return ServiceDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ServicePricingDto?> getServicePricing({int? serviceId, int? cityId}) async {
    final queryParameters = <String, dynamic>{};
    if (serviceId != null) queryParameters['serviceId'] = serviceId;
    if (cityId != null) queryParameters['cityId'] = cityId;
    final response = await _client.get(
      ApiConstants.servicePricings,
      queryParameters: queryParameters,
      includeAuth: false,
    );
    if (response is Map<String, dynamic>) return ServicePricingDto.fromJson(response);
    return null;
  }

  @override
  Future<List<ServicePricingDto>> getServicePricingsByService(int serviceId) async {
    final response = await _client.get(ApiConstants.servicePricingsByService(serviceId), includeAuth: false);
    if (response is! List) return [];
    return response.map((item) => ServicePricingDto.fromJson(item as Map<String, dynamic>)).toList();
  }
}
