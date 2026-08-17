import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/wallet_model.dart';

abstract class IWalletRepository {
  Future<WalletModel?> getWalletByTechnician(String technicianId);
  Future<List<WalletTransactionModel>> getTransactions(String walletId);
  Future<void> requestWithdrawal(String technicianId, double amount, String iban);

  Future<TechnicianWalletDto> getApiWalletById(int id);
  Future<TechnicianWalletDto> getApiCurrentWallet();
  Future<TechnicianWalletDto> createApiWallet(CreateTechnicianWalletRequest request);
  Future<TechnicianWalletDto> updateApiWallet(int id, UpdateTechnicianWalletRequest request);

  Future<WalletTransactionDto> getApiTransactionById(int id);
  Future<List<WalletTransactionDto>> getApiTransactionsByWalletId(int walletId);
  Future<WalletTransactionDto> createApiTransaction(CreateWalletTransactionRequest request);

  Future<PayoutDto> getApiPayoutById(int id);
  Future<List<PayoutDto>> getApiPayoutsForCurrentTechnician();
  Future<List<PayoutDto>> getApiPayoutsByTechnicianId(int technicianId);
  Future<PayoutDto> createApiPayout(CreatePayoutRequest request);
  Future<PayoutDto> updateApiPayout(int id, UpdatePayoutRequest request);
}

class WalletRepository implements IWalletRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<WalletModel?> getWalletByTechnician(String technicianId) async {
    final intId = int.tryParse(technicianId);
    if (intId == null) return null;

    final dto = await getApiCurrentWallet();
    final txs = await getTransactions(dto.id.toString());
    final payouts = await getApiPayoutsForCurrentTechnician();
    final totalWithdrawn = payouts.fold<double>(0.0, (sum, p) => sum + p.amount);

    return WalletModel(
      id: dto.id.toString(),
      technicianId: dto.technicianId.toString(),
      currentBalance: dto.balance,
      pendingBalance: payouts
          .where((p) => p.status.toLowerCase() == 'pending')
          .fold<double>(0.0, (sum, p) => sum + p.amount),
      totalEarnings: dto.balance + totalWithdrawn,
      totalWithdrawn: totalWithdrawn,
      transactions: txs,
    );
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions(String walletId) async {
    final intId = int.tryParse(walletId);
    if (intId == null) return [];

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
  }

  @override
  Future<void> requestWithdrawal(String technicianId, double amount, String iban) async {
    if (amount <= 0) throw ArgumentError('مبلغ السحب يجب أن يكون أكبر من صفر');
    if (iban.trim().isEmpty) throw ArgumentError('بيانات السحب مطلوبة');

    await createApiPayout(CreatePayoutRequest(
      amount: amount,
      paymentMethod: 'Bank Transfer: ${iban.trim()}',
    ));
  }

  @override
  Future<TechnicianWalletDto> getApiWalletById(int id) async {
    final response = await _client.get(ApiConstants.technicianWalletById(id));
    return TechnicianWalletDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TechnicianWalletDto> getApiCurrentWallet() async {
    final response = await _client.get(ApiConstants.myTechnicianWallet);
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
  Future<List<PayoutDto>> getApiPayoutsForCurrentTechnician() async {
    final response = await _client.get(ApiConstants.myPayouts);
    if (response is List) {
      return response.map((item) => PayoutDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
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
