import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../models/api_dtos.dart';
import '../../models/payment_model.dart';
import '../../models/service_request_model.dart';
import '../../repositories/promo_code_repository.dart';
import '../../services/app_state_provider.dart';

class CustomerPaymentScreen extends StatefulWidget {
  final ServiceRequestModel request;
  final double? amountToPay;
  final String paymentType;

  const CustomerPaymentScreen({
    super.key,
    required this.request,
    this.amountToPay,
    this.paymentType = 'FullService',
  });

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final PromoCodeRepository _promoRepository = PromoCodeRepository();
  final TextEditingController _promoController = TextEditingController();

  bool _submitting = false;
  bool _promoSubmitting = false;
  String? _errorMessage;
  String? _promoErrorMessage;
  List<PaymentModel> _payments = const [];
  UserPromoCodeDto? _appliedPromo;

  double get _amount => widget.amountToPay != null && widget.amountToPay! > 0
      ? widget.amountToPay!
      : widget.request.finalPrice != null && widget.request.finalPrice! > 0
          ? widget.request.finalPrice!
          : widget.request.estimatedPriceMin;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _loadAppliedPromo();
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
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'تعذر تحميل حالة الدفع. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<void> _loadAppliedPromo() async {
    final requestId = int.tryParse(widget.request.id);
    if (requestId == null) return;
    try {
      final applied = await _promoRepository.getUserPromoCodeByRequest(requestId);
      if (!mounted) return;
      setState(() => _appliedPromo = applied);
    } catch (_) {
      // A missing promo is a normal state; the payment screen remains usable.
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

    setState(() {
      _promoSubmitting = true;
      _promoErrorMessage = null;
    });

    try {
      final promo = await _promoRepository.getPromoCodeByCode(code);
      if (promo == null) {
        throw const FormatException('كود الخصم غير صالح أو غير موجود.');
      }

      // DiscountAmount is intentionally sent as zero. The backend's
      // UserPromoCodeService calculates and stores the authoritative discount;
      // the client never calculates the discount itself.
      final applied = await _promoRepository.createUserPromoCode(
        CreateUserPromoCodeRequest(
          userId: userId,
          promoCodeId: promo.id,
          serviceRequestId: requestId,
          discountAmount: 0,
        ),
      );

      if (!mounted) return;
      setState(() {
        _appliedPromo = applied;
        _promoController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'تعذر تطبيق كود الخصم. يرجى المحاولة مرة أخرى.';
      setState(() => _promoErrorMessage = message);
    } finally {
      if (mounted) setState(() => _promoSubmitting = false);
    }
  }

  Future<void> _chooseCash() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AppStateProvider>().selectCashOnDelivery(widget.request.id);
      if (!mounted) return;
      await _loadPayments();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم اختيار الدفع نقداً'),
          content: const Text('سيتم تسجيل الدفع النقدي على طلب الخدمة. لا يتم تأكيد الدفع الفعلي إلا وفق حالة الطلب والدفع في النظام.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : 'تعذر تسجيل الدفع النقدي. يرجى المحاولة مرة أخرى.';
        setState(() => _errorMessage = message);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePayment = _payments.cast<PaymentModel?>().firstWhere(
          (payment) => payment != null &&
              (payment.status == PaymentStatusType.pending || payment.status == PaymentStatusType.paid),
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الدفع')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('المبلغ المستحق', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    '${_amount.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  if (_appliedPromo != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_outlined, color: AppColors.successDark, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'خصم مؤكد من الخادم: ${_appliedPromo!.discountAmount.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(color: AppColors.successDark, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'المبلغ النهائي للدفع يظل معتمداً على سعر الحجز الذي يؤكده الخادم. لا يتم خصم القيمة محلياً.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('كود الخصم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (_appliedPromo != null)
                    const Text(
                      'تم تطبيق كود خصم على هذا الطلب بالفعل. لا يسمح الخادم بأكثر من كود واحد لكل طلب.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            enabled: !_promoSubmitting,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(hintText: 'أدخل كود الخصم'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _promoSubmitting ? null : _applyPromo,
                          child: _promoSubmitting
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('تطبيق'),
                        ),
                      ],
                    ),
                    if (_promoErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_promoErrorMessage!, style: const TextStyle(color: AppColors.errorDark)),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null)
            Card(
              color: AppColors.errorLight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.errorDark)),
              ),
            ),
          if (activePayment != null) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  activePayment.status == PaymentStatusType.paid
                      ? Icons.check_circle
                      : Icons.schedule,
                  color: activePayment.status == PaymentStatusType.paid
                      ? AppColors.successDark
                      : AppColors.warningDark,
                ),
                title: Text(activePayment.method.displayNameAr),
                subtitle: Text(activePayment.status.displayNameAr),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('طرق الدفع المتاحة حالياً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.money_rounded),
                    title: Text('الدفع نقداً'),
                    subtitle: Text('متاح عبر الـAPI الحالي.'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.credit_card_off_rounded),
                    title: Text('الدفع بالبطاقة / المحفظة الإلكترونية'),
                    subtitle: Text('غير متاح من واجهة العميل حالياً لأن الـbackend لا يعرّض endpoint للعميل لهذه العملية.'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _submitting || activePayment?.status == PaymentStatusType.paid ? null : _chooseCash,
                    icon: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.payments_rounded),
                    label: const Text('اختيار الدفع نقداً'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
