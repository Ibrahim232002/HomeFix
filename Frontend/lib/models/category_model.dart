class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String iconName;
  final String colorHex;
  final String image;
  final String descriptionAr;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.iconName,
    required this.colorHex,
    required this.image,
    required this.descriptionAr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'iconName': iconName,
        'color': colorHex,
        'image': image,
        'descriptionAr': descriptionAr,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] ?? '',
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
        iconName: json['iconName'] ?? 'Wrench',
        colorHex: json['color'] ?? '#0284c7',
        image: json['image'] ?? '',
        descriptionAr: json['descriptionAr'] ?? '',
      );
}
