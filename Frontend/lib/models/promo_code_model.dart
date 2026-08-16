class PromoCodeModel {
  final String code;
  final String title;
  final String discount;
  final String maxDiscount;
  final String description;
  final String expiry;
  final double discountPercentage;
  final double maxDiscountAmount;

  PromoCodeModel({
    required this.code,
    required this.title,
    required this.discount,
    required this.maxDiscount,
    required this.description,
    required this.expiry,
    required this.discountPercentage,
    required this.maxDiscountAmount,
  });
}
