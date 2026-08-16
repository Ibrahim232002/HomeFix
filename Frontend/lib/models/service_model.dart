class ServicePricingModel {
  final double minPrice;
  final double maxPrice;
  final double visitFee;
  final String currency;
  final String unit;

  ServicePricingModel({
    required this.minPrice,
    required this.maxPrice,
    required this.visitFee,
    this.currency = 'ج.م',
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'visitFee': visitFee,
        'currency': currency,
        'unit': unit,
      };

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) =>
      ServicePricingModel(
        minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
        visitFee: (json['visitFee'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] ?? 'ج.م',
        unit: json['unit'] ?? 'لكل زيارة',
      );
}

class ServiceModel {
  final String id;
  final String categoryId;
  final String categoryNameAr;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final ServicePricingModel pricing;
  final double rating;
  final int reviewCount;
  final String estimatedDuration;
  final String iconName;
  final String image;
  final List<String> features;
  final bool isPopular;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.categoryNameAr,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.pricing,
    required this.rating,
    required this.reviewCount,
    required this.estimatedDuration,
    required this.iconName,
    required this.image,
    required this.features,
    this.isPopular = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryNameAr': categoryNameAr,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'descriptionAr': descriptionAr,
        'descriptionEn': descriptionEn,
        'pricing': pricing.toJson(),
        'rating': rating,
        'reviewCount': reviewCount,
        'estimatedDuration': estimatedDuration,
        'iconName': iconName,
        'image': image,
        'features': features,
        'isPopular': isPopular,
      };

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'] ?? '',
        categoryId: json['categoryId'] ?? '',
        categoryNameAr: json['categoryNameAr'] ?? '',
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
        descriptionAr: json['descriptionAr'] ?? '',
        descriptionEn: json['descriptionEn'] ?? '',
        pricing: ServicePricingModel.fromJson(json['pricing'] ?? {}),
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        estimatedDuration: json['estimatedDuration'] ?? '1 ساعة',
        iconName: json['iconName'] ?? 'Wrench',
        image: json['image'] ?? '',
        features: (json['features'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        isPopular: json['isPopular'] ?? false,
      );
}
