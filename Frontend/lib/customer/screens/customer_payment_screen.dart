import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/payment_model.dart';
import '../../models/service_request_model.dart';
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
  bool _submitting = false;
  String? _errorMessage;
  List<PaymentModel> _payments = const [];

  double get _amount => widget.amountToPay != null && widget.amountToPay! > 0
      ? widget.amountToPay!
      : widget.request.finalPrice != null && widget.request.finalPrice! > 0
          ? widget.request.finalPrice!
          : widget.request.estimatedPriceMin;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final result = await context.read<AppStateProvider>().loadPaymentsForRequest(widget.request.id);
      if (mounted) setState(() => _payments = result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
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
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
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
