enum DocumentStatus {
  pending,
  approved,
  rejected;

  String get displayNameAr {
    switch (this) {
      case DocumentStatus.pending:
        return 'قيد المراجعة';
      case DocumentStatus.approved:
        return 'معتمد وموثق';
      case DocumentStatus.rejected:
        return 'مرفوض';
    }
  }

  static DocumentStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return DocumentStatus.approved;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  String get nameStr {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }
}

class TechnicianDocumentModel {
  final String id;
  final String technicianId;
  final String titleAr;
  final String titleEn;
  final String documentType; // 'NationalId' | 'CriminalRecord' | 'ProfessionalCertificate' | 'DriverLicense'
  final String? documentNumber;
  final String fileUrl;
  final DocumentStatus status;
  final String submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;

  TechnicianDocumentModel({
    required this.id,
    required this.technicianId,
    required this.titleAr,
    required this.titleEn,
    required this.documentType,
    this.documentNumber,
    required this.fileUrl,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'fileUrl': fileUrl,
        'status': status.nameStr,
        'submittedAt': submittedAt,
        'reviewedAt': reviewedAt,
        'rejectionReason': rejectionReason,
      };

  factory TechnicianDocumentModel.fromJson(Map<String, dynamic> json) =>
      TechnicianDocumentModel(
        id: json['id'] ?? '',
        technicianId: json['technicianId'] ?? '',
        titleAr: json['titleAr'] ?? '',
        titleEn: json['titleEn'] ?? '',
        documentType: json['documentType'] ?? 'NationalId',
        documentNumber: json['documentNumber'],
        fileUrl: json['fileUrl'] ?? '',
        status: DocumentStatus.fromString(json['status'] ?? 'Pending'),
        submittedAt: json['submittedAt'] ?? '',
        reviewedAt: json['reviewedAt'],
        rejectionReason: json['rejectionReason'],
      );
}
