import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/service_request_model.dart';
import '../../models/payment_model.dart';
import '../../models/api_dtos.dart';
import '../../services/app_state_provider.dart';

class CustomerPaymentScreen extends StatefulWidget {
  final ServiceRequestModel request;
  final double? amountToPay;
  final String paymentType; // 'VisitFee' or 'FullService'

  const CustomerPaymentScreen({
    Key? key,
    required this.request,
    this.amountToPay,
    this.paymentType = 'FullService',
  }) : super(key: key);

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.card;
  final TextEditingController _walletPhoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;
  bool _isVerifying = false;
  InitiatePaymentResponse? _initiateResponse;
  VerifyPaymentResponse? _verifyResponse;
  String? _errorMessage;
  Timer? _pollingTimer;
  int _pollCount = 0;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppStateProvider>(context, listen: false).currentUser;
    if (user != null && user.phoneNumber.isNotEmpty) {
      _walletPhoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _walletPhoneController.dispose();
    super.dispose();
  }

  double _getCalculatedTotal() {
    if (widget.amountToPay != null && widget.amountToPay! > 0) {
      return widget.amountToPay!;
    }
    if (widget.request.finalPrice != null && widget.request.finalPrice! > 0) {
      return widget.request.finalPrice!;
    }
    return widget.request.estimatedPriceMin;
  }

  Future<void> _handleInitiatePayment() async {
    if (_selectedMethod == PaymentMethodType.mobileWallet) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    try {
      if (_selectedMethod == PaymentMethodType.cashOnDelivery) {
        // Direct cash payment registration on backend
        await appState.selectCashOnDelivery(widget.request.id);
        setState(() {
          _isProcessing = false;
        });
        _showSuccessDialog(
          title: 'تم اختيار الدفع نقداً بنجاح',
          message: 'سيتم تسليم المبلغ المتفق عليه مباشرة للفني بعد انتهاء أعمال الصيانة والمعاينة.',
          reference: 'CASH-${widget.request.id}',
        );
        return;
      }

      // Real Egyptian Payment Gateway (Paymob) Initiation on ASP.NET Core Backend
      final response = await appState.initiatePayment(
        serviceRequestId: widget.request.id,
        method: _selectedMethod,
        walletPhoneNumber: _selectedMethod == PaymentMethodType.mobileWallet
            ? _walletPhoneController.text.trim()
            : null,
        paymentType: widget.paymentType,
      );

      setState(() {
        _isProcessing = false;
        _initiateResponse = response;
      });

      // Start automatic backend verification polling
      _startVerificationPolling(response.paymentId);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  void _startVerificationPolling(int paymentId) {
    _pollingTimer?.cancel();
    _pollCount = 0;
    setState(() => _isVerifying = true);

    // Poll every 3.5 seconds up to 10 attempts
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) async {
      _pollCount++;
      if (_pollCount > 12) {
        timer.cancel();
        if (mounted) {
          setState(() => _isVerifying = false);
        }
        return;
      }

      final appState = Provider.of<AppStateProvider>(context, listen: false);
      try {
        final verify = await appState.verifyPayment(paymentId);
        if (verify.isSuccess) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isVerifying = false;
              _verifyResponse = verify;
            });
            _showSuccessDialog(
              title: 'تم تأكيد الدفع الإلكتروني بنجاح!',
              message: 'تم استلام المبلغ وتحديث حالة طلب الصيانة #${widget.request.id}.',
              reference: verify.transactionReference ?? 'TXN-$paymentId',
            );
          }
        }
      } catch (_) {
        // Continue polling until timeout or success
      }
    });
  }

  Future<void> _manualVerify(int paymentId) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    try {
      final verify = await appState.verifyPayment(paymentId);
      setState(() {
        _isVerifying = false;
        _verifyResponse = verify;
      });

      if (verify.isSuccess) {
        _showSuccessDialog(
          title: 'تم تأكيد الدفع بنجاح!',
          message: 'تم التحقق من العملية بنجاح عبر بوابة الدفع.',
          reference: verify.transactionReference ?? 'TXN-$paymentId',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.warningDark,
            content: Text(verify.message.isNotEmpty
                ? verify.message
                : 'العملية ما زالت قيد المعالجة من قبل البنك، يرجى الانتظار قليلاً.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required String reference,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successDark, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.5)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('رقم المرجع:', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
                  Text(
                    reference,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('العودة لتفاصيل الطلب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTotal = _getCalculatedTotal();
    const double visitFee = 80.0;
    final double serviceFee = (calculatedTotal - visitFee).clamp(0, 99999).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سداد تكلفة الخدمة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.request.serviceNameAr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'طلب #${widget.request.id}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الموقع: ${widget.request.address.title} (${widget.request.address.city})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'),
                  ),
                  const Divider(height: 24),

                  // Price Breakdown
                  const Text(
                    'تفاصيل الفاتورة الرسمية',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceItem('رسوم الكشف والمعاينة المعتمدة', '${visitFee.toInt()}.00 ج.م'),
                  const SizedBox(height: 4),
                  _buildPriceItem('أجور صيانة وفحص الخدمة', '${serviceFee.toInt()}.00 ج.م'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي المبلغ المطلوب',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                      ),
                      Text(
                        '${calculatedTotal.toInt()}.00 ج.م',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // If active gateway response already initiated, show gateway payment card
            if (_initiateResponse != null && !_initiateResponse!.isCash) ...[
              _buildGatewayActiveCard(_initiateResponse!),
              const SizedBox(height: 16),
            ] else ...[
              // Payment Method Selector Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'اختر طريقة الدفع',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                          ),
                          Text(
                            'بوابة Paymob مصر',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Option 1: Card
                      _buildMethodOption(
                        method: PaymentMethodType.card,
                        title: 'البطاقة البنكية (Visa / MasterCard / ميزة)',
                        subtitle: 'دفع فوري آمن ومباشر عبر بوابة الدفع الإلكتروني',
                        icon: Icons.credit_card_rounded,
                        badges: ['فيزا', 'ماستركارد', 'ميزة'],
                      ),
                      const SizedBox(height: 10),

                      // Option 2: Mobile Wallet
                      _buildMethodOption(
                        method: PaymentMethodType.mobileWallet,
                        title: 'المحفظة الإلكترونية (فودافون كاش ومحافظ مصر)',
                        subtitle: 'فودافون كاش، أورنج، اتصالات، وي باي، والمحافظ البنكية',
                        icon: Icons.account_balance_wallet_rounded,
                        badges: ['فودافون كاش', 'أورنج', 'اتصالات', 'WE Pay'],
                      ),

                      if (_selectedMethod == PaymentMethodType.mobileWallet) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'رقم هاتف المحفظة الإلكترونية في مصر:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _walletPhoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  hintText: '010XXXXXXXX / 011XXXXXXXX',
                                  prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'يرجى إدخال رقم المحفظة الإلكترونية';
                                  }
                                  final clean = val.trim();
                                  if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(clean)) {
                                    return 'يرجى إدخال رقم مصري صحيح (مثال: 01012345678)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'سيصلك إشعار أو طلب تأكيد سداد من مزود محفظتك لإتمام الخصم.',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Option 3: Cash on delivery
                      _buildMethodOption(
                        method: PaymentMethodType.cashOnDelivery,
                        title: 'الدفع نقداً عند انتهاء الخدمة (Cash on Delivery)',
                        subtitle: 'تسليم المبلغ مباشرة للفني بعد انتهاء أعمال الصيانة',
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Security Notice Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'معاملاتك المالية مشفرة وآمنة وفق معايير PCI-DSS والبنك المركزي المصري. لا يتم حفظ بيانات بطاقتك أبداً في خوادمنا.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontFamily: 'Cairo', height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Error display if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.errorDark, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Primary Action Button
            if (_initiateResponse == null || _initiateResponse!.isCash)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : _handleInitiatePayment,
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text('جاري الاتصال ببوابة الدفع...', style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                        ],
                      )
                    : Text(
                        _selectedMethod == PaymentMethodType.cashOnDelivery
                            ? 'تأكيد اختيار الدفع نقداً'
                            : 'متابعة الدفع الإلكتروني (${calculatedTotal.toInt()} ج.م)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                      ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewayActiveCard(InitiatePaymentResponse resp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_clock_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جلسة الدفع الإلكتروني نشطة',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo'),
                    ),
                    Text(
                      'رقم العملية: ${resp.paymentId} • ${resp.currency} ${resp.amount}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          if (resp.paymentMethod == 'Card') ...[
            const Text(
              'يرجى إتمام عملية الدفع عبر واجهة Paymob الآمنة:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.link_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('رمز جلسة الدفع (Payment Key Token):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resp.paymentToken != null
                        ? '${resp.paymentToken!.substring(0, 30)}...'
                        : 'Token تم توليده بنجاح',
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ] else if (resp.paymentMethod == 'MobileWallet') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تم إرسال طلب الخصم إلى محفظتك الإلكترونية:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يرجى فتح تطبيق المحفظة على هاتفك وتأكيد عملية التحويل بقيمة ${resp.amount} ج.م.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1E3A8A), fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isVerifying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    _isVerifying ? 'جاري التحقق من الخادم...' : 'التحقق من حالة الدفع',
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _isVerifying ? null : () => _manualVerify(resp.paymentId),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    _initiateResponse = null;
                    _isVerifying = false;
                  });
                  _pollingTimer?.cancel();
                },
                child: const Text('إلغاء وتغيير الطريقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption({
    required PaymentMethodType method,
    required String title,
    required String subtitle,
    required IconData icon,
    List<String>? badges,
  }) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<PaymentMethodType>(
              value: method,
              groupValue: _selectedMethod,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMethod = val;
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(width: 6),
            Icon(icon, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                  ),
                  if (badges != null && badges.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: badges.map((b) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(b, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
        Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo')),
      ],
    );
  }
}
