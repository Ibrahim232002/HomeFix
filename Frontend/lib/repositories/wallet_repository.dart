import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/wallet_model.dart';

abstract class IWalletRepository {
  Future<WalletModel?> getWalletByTechnician(String technicianId);
  Future<List<WalletTransactionModel>> getTransactions(String walletId);
  Future<void> requestWithdrawal(String technicianId, double amount, String iban);

  // Direct OpenAPI DTO methods
  Future<TechnicianWalletDto> getApiWalletById(int id);
  Future<TechnicianWalletDto> getApiWalletByTechnicianId(int technicianId);
  Future<TechnicianWalletDto> createApiWallet(CreateTechnicianWalletRequest request);
  Future<TechnicianWalletDto> updateApiWallet(int id, UpdateTechnicianWalletRequest request);

  Future<WalletTransactionDto> getApiTransactionById(int id);
  Future<List<WalletTransactionDto>> getApiTransactionsByWalletId(int walletId);
  Future<WalletTransactionDto> createApiTransaction(CreateWalletTransactionRequest request);

  Future<PayoutDto> getApiPayoutById(int id);
  Future<List<PayoutDto>> getApiPayoutsByTechnicianId(int technicianId);
  Future<PayoutDto> createApiPayout(CreatePayoutRequest request);
  Future<PayoutDto> updateApiPayout(int id, UpdatePayoutRequest request);
}

class WalletRepository implements IWalletRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<WalletModel?> getWalletByTechnician(String technicianId) async {
    final intId = int.tryParse(technicianId);
    if (intId != null) {
      try {
        final dto = await getApiWalletByTechnicianId(intId);
        final txs = await getTransactions(dto.id.toString());
        final payouts = await getApiPayoutsByTechnicianId(intId);
        final totalWithdrawn = payouts.fold<double>(0.0, (sum, p) => sum + p.amount);
        return WalletModel(
          id: dto.id.toString(),
          technicianId: dto.technicianId.toString(),
          currentBalance: dto.balance,
          pendingBalance: 0.0,
          totalEarnings: dto.balance + totalWithdrawn,
          totalWithdrawn: totalWithdrawn,
          transactions: txs,
        );
      } catch (_) {
        // Safe fallback for technician without created wallet yet
        return WalletModel(
          id: '',
          technicianId: technicianId,
          currentBalance: 0.0,
          pendingBalance: 0.0,
          totalEarnings: 0.0,
          totalWithdrawn: 0.0,
          transactions: [],
        );
      }
    }
    return null;
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions(String walletId) async {
    final intId = int.tryParse(walletId);
    if (intId != null) {
      try {
        final dtos = await getApiTransactionsByWalletId(intId);
        return dtos
            .map((d) => WalletTransactionModel(
                  id: d.id.toString(),
                  walletId: d.walletId.toString(),
                  technicianId: '',
                  serviceRequestId: d.serviceRequestId?.toString(),
                  type: (d.transactionType?.toLowerCase() == 'payout' || d.amount < 0)
                      ? TransactionType.withdrawal
                      : TransactionType.earnings,
                  amount: d.amount.abs(),
                  titleAr: d.description ?? 'حركة رصيد',
                  descriptionAr: d.transactionType ?? '',
                  date: d.createdAt,
                  status: 'Completed',
                ))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<void> requestWithdrawal(String technicianId, double amount, String iban) async {
    final intId = int.tryParse(technicianId);
    if (intId != null) {
      try {
        await createApiPayout(CreatePayoutRequest(
          technicianId: intId,
          amount: amount,
          paymentMethod: 'Bank Transfer: $iban',
        ));
      } catch (_) {}
    }
  }

  // --- Direct OpenAPI Implementations ---
  @override
  Future<TechnicianWalletDto> getApiWalletById(int id) async {
    final response = await _client.get(ApiConstants.technicianWalletById(id));
    return TechnicianWalletDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianWalletDto> getApiWalletByTechnicianId(int technicianId) async {
    final response = await _client.get(ApiConstants.technicianWalletByTechnician(technicianId));
    return TechnicianWalletDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianWalletDto> createApiWallet(CreateTechnicianWalletRequest request) async {
    final response = await _client.post(ApiConstants.technicianWallets, body: request.toJson());
    return TechnicianWalletDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianWalletDto> updateApiWallet(int id, UpdateTechnicianWalletRequest request) async {
    final response = await _client.put(ApiConstants.technicianWalletById(id), body: request.toJson());
    return TechnicianWalletDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<WalletTransactionDto> getApiTransactionById(int id) async {
    final response = await _client.get(ApiConstants.walletTransactionById(id));
    return WalletTransactionDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<WalletTransactionDto>> getApiTransactionsByWalletId(int walletId) async {
    final response = await _client.get(ApiConstants.walletTransactionsByWallet(walletId));
    if (response is List) {
      return response.map((item) => WalletTransactionDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<WalletTransactionDto> createApiTransaction(CreateWalletTransactionRequest request) async {
    final response = await _client.post(ApiConstants.walletTransactions, body: request.toJson());
    return WalletTransactionDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PayoutDto> getApiPayoutById(int id) async {
    final response = await _client.get(ApiConstants.payoutById(id));
    return PayoutDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<PayoutDto>> getApiPayoutsByTechnicianId(int technicianId) async {
    final response = await _client.get(ApiConstants.payoutsByTechnician(technicianId));
    if (response is List) {
      return response.map((item) => PayoutDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<PayoutDto> createApiPayout(CreatePayoutRequest request) async {
    final response = await _client.post(ApiConstants.payouts, body: request.toJson());
    return PayoutDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PayoutDto> updateApiPayout(int id, UpdatePayoutRequest request) async {
    final response = await _client.put(ApiConstants.payoutById(id), body: request.toJson());
    return PayoutDto.fromJson(response as Map<String, dynamic>);
  }
}
