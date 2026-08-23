import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../models/booking_model.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/booking_repository.dart';

class CustomerPaymentScreen extends StatefulWidget {
  final ServiceRequestModel request;
  final double? amountToPay;
  final String paymentType;

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
  bool _isProcessing = false;
  bool _checkingBooking = true;
  BookingModel? _booking;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBooking();
  }

  Future<void> _checkBooking() async {
    final requestId = int.tryParse(widget.request.id);
    if (requestId == null || requestId <= 0) {
      if (mounted) {
        setState(() {
          _checkingBooking = false;
          _booking = null;
          _errorMessage = 'معرف طلب الخدمة غير صالح.';
        });
      }
      return;
    }

    try {
      final booking = await BookingRepository().getBookingByRequest(widget.request.id);
      if (!mounted) return;
      setState(() {
        _checkingBooking = false;
        _booking = booking;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 404) {
        setState(() {
          _checkingBooking = false;
          _booking = null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _checkingBooking = false;
          _booking = null;
          _errorMessage = error.message;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checkingBooking = false;
        _booking = null;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double? _getPaymentTotal() {
    if (widget.amountToPay != null && widget.amountToPay! > 0) return widget.amountToPay;
    final bookingAmount = _booking?.finalPrice ?? _booking?.agreedPrice;
    if (bookingAmount != null && bookingAmount > 0) return bookingAmount;
    if (widget.request.finalPrice != null && widget.request.finalPrice! > 0) return widget.request.finalPrice;
    return null;
  }

  bool get _hasConfirmedBookingForPayment {
    final booking = _booking;
    if (booking == null || !booking.status.isActive) return false;
    final agreedOrFinal = booking.finalPrice ?? booking.agreedPrice;
    return agreedOrFinal != null && agreedOrFinal > 0;
  }

  Future<void> _selectCash() async {
    if (_checkingBooking) return;
    if (_errorMessage != null) return;
    if (!_hasConfirmedBookingForPayment) {
      setState(() => _errorMessage = 'السداد متاح بعد تأكيد الحجز وتحديد السعر المتفق عليه.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AppStateProvider>(context, listen: false).selectCashOnDelivery(widget.request.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.successDark, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('تم اختيار الدفع نقداً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
            ],
          ),
          content: const Text('تم تسجيل اختيار الدفع النقدي لهذا الطلب. سيتم سداد المبلغ المتفق عليه للفني وفق حالة الحجز الحالية.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.5)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('العودة لتفاصيل الطلب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', '').trim());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentTotal = _getPaymentTotal();
    final visitFee = widget.request.visitFee;
    final serviceFee = paymentTotal != null && visitFee != null && paymentTotal >= visitFee
        ? paymentTotal - visitFee
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('سداد تكلفة الخدمة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.request.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'))),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: Text('طلب #${widget.request.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontFamily: 'Cairo'))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('الموقع: ${widget.request.address.title} (${widget.request.address.city})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
                  const Divider(height: 24),
                  const Text('تفاصيل الفاتورة الرسمية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  if (visitFee != null) _buildPriceItem('رسوم الزيارة المعتمدة', '${visitFee.toStringAsFixed(2)} ج.م'),
                  if (visitFee != null && serviceFee != null) const SizedBox(height: 4),
                  if (serviceFee != null) _buildPriceItem('أجور الصيانة والفحص', '${serviceFee.toStringAsFixed(2)} ج.م'),
                  if (visitFee == null && serviceFee == null) const Text('لا توجد بيانات تفصيلية كافية للسعر حالياً.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Text('إجمالي المبلغ المطلوب', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Cairo'))),
                      Text(paymentTotal == null ? 'غير متاح' : '${paymentTotal.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_checkingBooking)
              const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error)),
                child: Row(children: const [Icon(Icons.error_outline_rounded, color: AppColors.errorDark, size: 22), SizedBox(width: 10), Expanded(child: Text('تعذر التحقق من حالة الحجز حالياً. راجع رسالة الخطأ الظاهرة أدناه ثم أعد المحاولة.', style: TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo', height: 1.5)))]),
              )
            else if (!_hasConfirmedBookingForPayment)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error)),
                child: const Row(children: [Icon(Icons.lock_outline_rounded, color: AppColors.errorDark, size: 22), SizedBox(width: 10), Expanded(child: Text('السداد غير متاح حالياً. يصبح الدفع متاحاً بعد تأكيد الحجز مع الفني وتحديد السعر المتفق عليه.', style: TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo', height: 1.5)))]),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('طرق الدفع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                  const SizedBox(height: 12),
                  _buildUnsupportedMethod(Icons.credit_card_rounded, 'Visa / MasterCard / ميزة', 'غير متاح حالياً: لا يوجد endpoint عميل للدفع الإلكتروني في الـAPI الحالي.'),
                  const SizedBox(height: 10),
                  _buildUnsupportedMethod(Icons.account_balance_wallet_rounded, 'المحفظة الإلكترونية', 'غير متاح حالياً: لا يوجد endpoint عميل فعّال للمحافظ في الـAPI الحالي.'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.35), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
                    child: Row(
                      children: const [
                        Icon(Icons.payments_outlined, color: AppColors.primaryDark, size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الدفع نقداً', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontFamily: 'Cairo')), SizedBox(height: 2), Text('متاح بعد وجود حجز مؤكد وسعر متفق عليه.', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'))])),
                        Radio<bool>(value: true, groupValue: true, onChanged: null, activeColor: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error)),
                child: Row(children: [const Icon(Icons.error_outline_rounded, color: AppColors.errorDark, size: 20), const SizedBox(width: 8), Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo')))]),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _isProcessing || _checkingBooking || !_hasConfirmedBookingForPayment || _errorMessage != null ? null : _selectCash,
              child: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('تأكيد اختيار الدفع نقداً', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedMethod(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [Icon(icon, color: AppColors.textMuted, size: 24), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo')), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'))])), const Chip(label: Text('غير متاح', style: TextStyle(fontSize: 10, fontFamily: 'Cairo')))]),
    );
  }

  Widget _buildPriceItem(String label, String amount) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))), const SizedBox(width: 8), Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo'))]);
}
