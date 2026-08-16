class ReviewModel {
  final String id;
  final String requestId;
  final String technicianId;
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  final double rating; // 1.0 to 5.0
  final String comment;
  final String createdAt;
  final String serviceNameAr;

  ReviewModel({
    required this.id,
    required this.requestId,
    required this.technicianId,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.serviceNameAr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestId': requestId,
        'technicianId': technicianId,
        'customerId': customerId,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
        'serviceNameAr': serviceNameAr,
      };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] ?? '',
        requestId: json['requestId'] ?? '',
        technicianId: json['technicianId'] ?? '',
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'] ?? '',
        customerAvatar: json['customerAvatar'],
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        comment: json['comment'] ?? '',
        createdAt: json['createdAt'] ?? '',
        serviceNameAr: json['serviceNameAr'] ?? '',
      );
}
