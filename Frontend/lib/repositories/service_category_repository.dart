import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class IServiceCategoryRepository {
  Future<List<CategoryModel>> getCategories();
}

class ServiceCategoryRepository implements IServiceCategoryRepository {
  ServiceCategoryRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get(
      ApiConstants.serviceCategories,
      includeAuth: false,
    );

    if (response is! List) return [];

    return response
        .map((item) => item as Map<String, dynamic>)
        .where((item) => item['isActive'] != false)
        .map(
          (item) => CategoryModel(
            id: item['id']?.toString() ?? '',
            nameAr: item['name']?.toString() ?? '',
            nameEn: item['name']?.toString() ?? '',
            iconName: item['iconName']?.toString().isNotEmpty == true
                ? item['iconName'].toString()
                : 'Wrench',
            colorHex: '#0284c7',
            image: item['imageUrl']?.toString() ?? '',
            descriptionAr: item['description']?.toString() ?? '',
          ),
        )
        .where((category) => category.id.isNotEmpty && category.nameAr.isNotEmpty)
        .toList();
  }
}