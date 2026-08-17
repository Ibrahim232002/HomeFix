import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../models/payment_model.dart';
import '../../models/service_request_model.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/promo_code_repository.dart';
import '../../services/app_state_provider.dart';

class CustomerPaymentScreen extends StatefulWidget {
  final ServiceRequestModel request;
  final double? amountToPay;
  final String paymentType;

  const CustomerPaymentScreen({super.key, required this.request, this.amountToPay, this.paymentType = 'FullService'});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final PromoCodeRepository _promoRepository = PromoCodeRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final TextEditingController _promoController = TextEditingController();
  bool _submitting = false;
  bool _promoSubmitting = false;
  bool _loadingAmount = true;
  String? _errorMessage;
  String? _promoErrorMessage;
  List<PaymentModel> _payments = const [];
  UserPromoCodeDto? _appliedPromo;
  double? _serverPayableAmount;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _loadAppliedPromo();
    _loadPayableAmount();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      final result = await context.read<AppStateProvider>().loadPaymentsForRequest(widget.request.id);
      if (mounted) setState(() => _payments = result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e is ApiException ? e.message : 'تعذر تحميل حالة الدفع.');
    }
  }

  Future<void> _loadAppliedPromo() async {
    final requestId = int.tryParse(widget.request.id);
    if (requestId == null) return;
    try {
      final applied = await _promoRepository.getUserPromoCodeByRequest(requestId);
      if (mounted) setState(() => _appliedPromo = applied);
    } catch (_) {
      // Absence of an applied promo is a normal state.
    }
  }

  Future<void> _loadPayableAmount() async {
    final requestId = int.tryParse(widget.request.id);
    if (requestId == null) return;
    setState(() { _loadingAmount = true; _errorMessage = null; });
    try {
      final amount = await _paymentRepository.getPayableAmountByRequest(requestId);
      if (!mounted) return;
      setState(() { _serverPayableAmount = amount; _loadingAmount = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadingAmount = false; _serverPayableAmount = null; _errorMessage = e is ApiException ? e.message : 'تعذر تحميل المبلغ المستحق من الخادم.'; });
    }
  }

  Future<void> _applyPromo() async {
    if (_promoSubmitting || _appliedPromo != null) return;
    final code = _promoController.text.trim();
    final requestId = int.tryParse(widget.request.id);
    final userId = int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');
    if (requestId == null || userId == null || code.isEmpty) {
      setState(() => _promoErrorMessage = 'أدخل كود خصم صالحاً.');
      return;
    }
    setState(() { _promoSubmitting = true; _promoErrorMessage = null; });
    try {
      final promo = await _promoRepository.getPromoCodeByCode(code);
      if (promo == null) throw const FormatException('كود الخصم غير صالح أو غير موجود.');
      final applied = await _promoRepository.createUserPromoCode(CreateUserPromoCodeRequest(userId: userId, promoCodeId: promo.id, serviceRequestId: requestId, discountAmount: 0));
      if (!mounted) return;
      setState(() { _appliedPromo = applied; _promoController.clear(); });
      await _loadPayableAmount();
    } catch (e) {
      if (mounted) setState(() => _promoErrorMessage = e is ApiException ? e.message : 'تعذر تطبيق كود الخصم.');
    } finally {
      if (mounted) setState(() => _promoSubmitting = false);
    }
  }

  Future<void> _chooseCash() async {
    if (_submitting || _loadingAmount || _serverPayableAmount == null) return;
    setState(() { _submitting = true; _errorMessage = null; });
    try {
      await context.read<AppStateProvider>().selectCashOnDelivery(widget.request.id);
      await _loadPayments();
      await _loadPayableAmount();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تم تسجيل الدفع النقدي'),
          content: const Text('تم إرسال عملية الدفع النقدي إلى الخادم. حالة الدفع الفعلية تبقى مرتبطة بحالة الطلب والدفع في النظام.'),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('حسناً'))],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e is ApiException ? e.message : 'تعذر تسجيل الدفع النقدي. يرجى المحاولة مرة أخرى.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePayment = _payments.cast<PaymentModel?>().firstWhere((payment) => payment != null && (payment.status == PaymentStatusType.pending || payment.status == PaymentStatusType.paid), orElse: () => null);
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الدفع')),
      body: RefreshIndicator(
        onRefresh: () async { await _loadPayments(); await _loadAppliedPromo(); await _loadPayableAmount(); },
        child: ListView(
          padding: padding.add(const EdgeInsets.only(bottom: 32)),
          children: [
            AppResponsive.content(context, child: HomeFixCard(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
              borderColor: Colors.transparent,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('المبلغ المستحق', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: AppDesignTokens.space2),
                if (_loadingAmount)
                  const HomeFixSkeleton(width: 170, height: 30, radius: AppDesignTokens.radiusSm)
                else if (_serverPayableAmount != null)
                  Text('${_serverPayableAmount!.toStringAsFixed(2)} ج.م', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900))
                else
                  const Text('تعذر تحميل المبلغ', style: TextStyle(color: Colors.white)),
                if (_appliedPromo != null) ...[
                  const SizedBox(height: AppDesignTokens.space3),
                  HomeFixStatusChip(label: 'خصم مؤكد ${_appliedPromo!.discountAmount.toStringAsFixed(2)} ج.م', tone: HomeFixStatusTone.success, icon: Icons.local_offer_outlined),
                ],
              ]),
            )),
            const SizedBox(height: AppDesignTokens.space4),
            AppResponsive.content(context, child: HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('كود الخصم', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppDesignTokens.space3),
              if (_appliedPromo != null)
                Text('تم تطبيق كود خصم لهذا الطلب بالفعل. لا يسمح الخادم بتطبيق أكثر من كود واحد.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
              else ...[
                Row(children: [
                  Expanded(child: TextField(controller: _promoController, enabled: !_promoSubmitting, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: 'أدخل كود الخصم'))),
                  const SizedBox(width: AppDesignTokens.space2),
                  HomeFixButton(expanded: false, loading: _promoSubmitting, label: 'تطبيق', variant: HomeFixButtonVariant.secondary, onPressed: _applyPromo),
                ]),
                if (_promoErrorMessage != null) ...[
                  const SizedBox(height: AppDesignTokens.space2),
                  Text(_promoErrorMessage!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.errorDark)),
                ],
              ],
            ]))),
            const SizedBox(height: AppDesignTokens.space4),
            if (_errorMessage != null) AppResponsive.content(context, child: Padding(padding: const EdgeInsets.only(bottom: AppDesignTokens.space4), child: HomeFixErrorState(title: 'تعذر إكمال الدفع', message: _errorMessage, onRetry: _loadPayableAmount))),
            if (activePayment != null) ...[
              AppResponsive.content(context, child: HomeFixCard(child: Row(children: [
                Icon(activePayment.status == PaymentStatusType.paid ? Icons.check_circle_rounded : Icons.schedule_rounded, color: activePayment.status == PaymentStatusType.paid ? AppColors.successDark : AppColors.warningDark),
                const SizedBox(width: AppDesignTokens.space3),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activePayment.method.displayNameAr, style: Theme.of(context).textTheme.titleSmall), Text(activePayment.status.displayNameAr, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))])),
              ]))),
              const SizedBox(height: AppDesignTokens.space4),
            ],
            AppResponsive.content(context, child: HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('طريقة الدفع', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppDesignTokens.space3),
              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.payments_outlined), title: Text('الدفع نقداً'), subtitle: Text('متاح في التدفق الحالي.')),
              const Divider(),
              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.credit_card_off_outlined), title: Text('البطاقة / المحفظة الإلكترونية'), subtitle: Text('غير متاحان حالياً من واجهة العميل لأن الـbackend لا يوفّر التدفق المطلوب.')),
              const SizedBox(height: AppDesignTokens.space3),
              HomeFixButton(label: 'اختيار الدفع نقداً', icon: Icons.money_rounded, loading: _submitting, onPressed: (_submitting || _loadingAmount || _serverPayableAmount == null || activePayment?.status == PaymentStatusType.paid) ? null : _chooseCash),
            ]))),
          ],
        ),
      ),
    );
  }
}
