enum TransactionType {
  earnings,
  withdrawal,
  bonus,
  commissionDeduction;

  String get displayNameAr {
    switch (this) {
      case TransactionType.earnings:
        return 'إيراد خدمة';
      case TransactionType.withdrawal:
        return 'سحب رصيد';
      case TransactionType.bonus:
        return 'مكافأة أداء';
      case TransactionType.commissionDeduction:
        return 'عمولة المنصة';
    }
  }

  static TransactionType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'withdrawal':
      case 'payout':
        return TransactionType.withdrawal;
      case 'bonus':
        return TransactionType.bonus;
      case 'commissiondeduction':
        return TransactionType.commissionDeduction;
      default:
        return TransactionType.earnings;
    }
  }

  String get nameStr {
    switch (this) {
      case TransactionType.earnings:
        return 'Earnings';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.commissionDeduction:
        return 'CommissionDeduction';
    }
  }
}

class WalletTransactionModel {
  final String id;
  final String walletId;
  final String technicianId;
  final String? serviceRequestId;
  final double amount;
  final TransactionType type;
  final String titleAr;
  final String descriptionAr;
  final String date;
  final String status; // 'Completed' | 'Pending' | 'Failed'
  final String? referenceId;

  WalletTransactionModel({
    required this.id,
    this.walletId = '',
    this.technicianId = '',
    this.serviceRequestId,
    required this.amount,
    required this.type,
    required this.titleAr,
    required this.descriptionAr,
    required this.date,
    this.status = 'Completed',
    this.referenceId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'walletId': walletId,
        'technicianId': technicianId,
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'type': type.nameStr,
        'titleAr': titleAr,
        'descriptionAr': descriptionAr,
        'date': date,
        'status': status,
        'referenceId': referenceId,
      };

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: (json['id'] ?? '').toString(),
        walletId: (json['walletId'] ?? '').toString(),
        technicianId: (json['technicianId'] ?? '').toString(),
        serviceRequestId: json['serviceRequestId']?.toString(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: TransactionType.fromString(json['type'] ?? json['transactionType'] ?? 'Earnings'),
        titleAr: json['titleAr'] ?? json['description'] ?? 'حركة رصيد',
        descriptionAr: json['descriptionAr'] ?? json['transactionType'] ?? '',
        date: json['date'] ?? json['createdAt'] ?? '',
        status: json['status'] ?? 'Completed',
        referenceId: json['referenceId']?.toString(),
      );
}

class TechnicianWalletModel {
  final String id;
  final String technicianId;
  final double currentBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalWithdrawn;
  final List<WalletTransactionModel> transactions;

  TechnicianWalletModel({
    this.id = '',
    required this.technicianId,
    required this.currentBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    this.totalWithdrawn = 0.0,
    required this.transactions,
  });

  TechnicianWalletModel copyWith({
    String? id,
    String? technicianId,
    double? currentBalance,
    double? pendingBalance,
    double? totalEarnings,
    double? totalWithdrawn,
    List<WalletTransactionModel>? transactions,
  }) {
    return TechnicianWalletModel(
      id: id ?? this.id,
      technicianId: technicianId ?? this.technicianId,
      currentBalance: currentBalance ?? this.currentBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      transactions: transactions ?? this.transactions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'currentBalance': currentBalance,
        'pendingBalance': pendingBalance,
        'totalEarnings': totalEarnings,
        'totalWithdrawn': totalWithdrawn,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory TechnicianWalletModel.fromJson(Map<String, dynamic> json) =>
      TechnicianWalletModel(
        id: (json['id'] ?? '').toString(),
        technicianId: (json['technicianId'] ?? '').toString(),
        currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? (json['balance'] as num?)?.toDouble() ?? 0.0,
        pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
        totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
        totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
        transactions: (json['transactions'] as List<dynamic>? ?? [])
            .map((t) => WalletTransactionModel.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

typedef WalletModel = TechnicianWalletModel;

