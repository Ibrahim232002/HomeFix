import 'address_model.dart';

enum ServiceRequestStatus {
  pending,
  open,
  offerPending,
  accepted,
  scheduled,
  inProgress,
  completed,
  cancelled;

  String get displayNameAr {
    switch (this) {
      case ServiceRequestStatus.pending:
        return 'قيد الانتظار';
      case ServiceRequestStatus.open:
        return 'مفتوح';
      case ServiceRequestStatus.offerPending:
        return 'بانتظار عروض الفنيين';
      case ServiceRequestStatus.accepted:
        return 'تم القبول';
      case ServiceRequestStatus.scheduled:
        return 'مجدول';
      case ServiceRequestStatus.inProgress:
        return 'جاري التنفيذ';
      case ServiceRequestStatus.completed:
        return 'مكتمل';
      case ServiceRequestStatus.cancelled:
        return 'ملغي';
    }
  }

  static ServiceRequestStatus fromString(String val) {
    switch (val.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return ServiceRequestStatus.pending;
      case 'open':
        return ServiceRequestStatus.open;
      case 'offerpending':
        return ServiceRequestStatus.offerPending;
      case 'accepted':
        return ServiceRequestStatus.accepted;
      case 'scheduled':
        return ServiceRequestStatus.scheduled;
      case 'inprogress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
      case 'canceled':
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.pending;
    }
  }

  String get nameStr {
    switch (this) {
      case ServiceRequestStatus.pending:
        return 'Pending';
      case ServiceRequestStatus.open:
        return 'Open';
      case ServiceRequestStatus.offerPending:
        return 'OfferPending';
      case ServiceRequestStatus.accepted:
        return 'Accepted';
      case ServiceRequestStatus.scheduled:
        return 'Scheduled';
      case ServiceRequestStatus.inProgress:
        return 'InProgress';
      case ServiceRequestStatus.completed:
        return 'Completed';
      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ServiceRequestFileModel {
  final String id;
  final String fileName;
  final String url;
  final String type;
  final String uploadedAt;

  ServiceRequestFileModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'url': url,
        'type': type,
        'uploadedAt': uploadedAt,
      };

  factory ServiceRequestFileModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestFileModel(
        id: json['id'] ?? '',
        fileName: json['fileName'] ?? '',
        url: json['url'] ?? '',
        type: json['type'] ?? 'image',
        uploadedAt: json['uploadedAt'] ?? '',
      );
}

class ServiceRequestStatusHistoryModel {
  final ServiceRequestStatus status;
  final String timestamp;
  final String? notes;
  final String updatedBy;

  ServiceRequestStatusHistoryModel({
    required this.status,
    required this.timestamp,
    this.notes,
    required this.updatedBy,
  });

  Map<String, dynamic> toJson() => {
        'status': status.nameStr,
        'timestamp': timestamp,
        'notes': notes,
        'updatedBy': updatedBy,
      };

  factory ServiceRequestStatusHistoryModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestStatusHistoryModel(
        status: ServiceRequestStatus.fromString(json['status'] ?? 'Pending'),
        timestamp: json['timestamp'] ?? '',
        notes: json['notes'],
        updatedBy: json['updatedBy'] ?? '',
      );
}

class ServiceRequestModel {
  final String id;
  final String serviceId;
  final String serviceNameAr;
  final String categoryNameAr;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? technicianId;
  final String? technicianName;
  final String? technicianAvatar;
  final String? technicianPhone;
  final AddressModel address;
  final String problemDescription;
  final String preferredDate;
  final String preferredTime;
  final List<ServiceRequestFileModel> files;
  final ServiceRequestStatus status;
  final double? visitFee;
  final double estimatedPriceMin;
  final double estimatedPriceMax;
  final double? finalPrice;
  final String createdAt;
  final List<ServiceRequestStatusHistoryModel> statusHistory;
  final String? cancellationReason;
  final String? notes;

  ServiceRequestModel({
    required this.id,
    required this.serviceId,
    required this.serviceNameAr,
    required this.categoryNameAr,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.technicianId,
    this.technicianName,
    this.technicianAvatar,
    this.technicianPhone,
    required this.address,
    required this.problemDescription,
    required this.preferredDate,
    required this.preferredTime,
    required this.files,
    required this.status,
    this.visitFee,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    this.finalPrice,
    required this.createdAt,
    required this.statusHistory,
    this.cancellationReason,
    this.notes,
  });

  ServiceRequestModel copyWith({
    String? id,
    String? serviceId,
    String? serviceNameAr,
    String? categoryNameAr,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? technicianId,
    String? technicianName,
    String? technicianAvatar,
    String? technicianPhone,
    AddressModel? address,
    String? problemDescription,
    String? preferredDate,
    String? preferredTime,
    List<ServiceRequestFileModel>? files,
    ServiceRequestStatus? status,
    double? visitFee,
    double? estimatedPriceMin,
    double? estimatedPriceMax,
    double? finalPrice,
    String? createdAt,
    List<ServiceRequestStatusHistoryModel>? statusHistory,
    String? cancellationReason,
    String? notes,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianAvatar: technicianAvatar ?? this.technicianAvatar,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      address: address ?? this.address,
      problemDescription: problemDescription ?? this.problemDescription,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      files: files ?? this.files,
      status: status ?? this.status,
      visitFee: visitFee ?? this.visitFee,
      estimatedPriceMin: estimatedPriceMin ?? this.estimatedPriceMin,
      estimatedPriceMax: estimatedPriceMax ?? this.estimatedPriceMax,
      finalPrice: finalPrice ?? this.finalPrice,
      createdAt: createdAt ?? this.createdAt,
      statusHistory: statusHistory ?? this.statusHistory,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceNameAr': serviceNameAr,
        'categoryNameAr': categoryNameAr,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'technicianAvatar': technicianAvatar,
        'technicianPhone': technicianPhone,
        'address': address.toJson(),
        'problemDescription': problemDescription,
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'files': files.map((f) => f.toJson()).toList(),
        'status': status.nameStr,
        'visitFee': visitFee,
        'estimatedPriceMin': estimatedPriceMin,
        'estimatedPriceMax': estimatedPriceMax,
        'finalPrice': finalPrice,
        'createdAt': createdAt,
        'statusHistory': statusHistory.map((s) => s.toJson()).toList(),
        'cancellationReason': cancellationReason,
        'notes': notes,
      };

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestModel(
        id: json['id'] ?? '',
        serviceId: json['serviceId'] ?? '',
        serviceNameAr: json['serviceNameAr'] ?? '',
        categoryNameAr: json['categoryNameAr'] ?? '',
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'] ?? '',
        customerPhone: json['customerPhone'] ?? '',
        technicianId: json['technicianId'],
        technicianName: json['technicianName'],
        technicianAvatar: json['technicianAvatar'],
        technicianPhone: json['technicianPhone'],
        address: AddressModel.fromJson(json['address'] ?? {}),
        problemDescription: json['problemDescription'] ?? '',
        preferredDate: json['preferredDate'] ?? '',
        preferredTime: json['preferredTime'] ?? '',
        files: (json['files'] as List<dynamic>? ?? [])
            .map((f) => ServiceRequestFileModel.fromJson(f))
            .toList(),
        status: ServiceRequestStatus.fromString(json['status'] ?? 'Pending'),
        visitFee: (json['visitFee'] as num?)?.toDouble(),
        estimatedPriceMin: (json['estimatedPriceMin'] as num?)?.toDouble() ?? 0.0,
        estimatedPriceMax: (json['estimatedPriceMax'] as num?)?.toDouble() ?? 0.0,
        finalPrice: (json['finalPrice'] as num?)?.toDouble(),
        createdAt: json['createdAt'] ?? '',
        statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
            .map((s) => ServiceRequestStatusHistoryModel.fromJson(s))
            .toList(),
        cancellationReason: json['cancellationReason'],
        notes: json['notes'],
      );
}