import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/booking_repository.dart';
import '../../common/screens/chat_detail_screen.dart';
import '../../common/widgets/review_dialog.dart';
import 'customer_payment_screen.dart';

class CustomerRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const CustomerRequestDetailScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  State<CustomerRequestDetailScreen> createState() => _CustomerRequestDetailScreenState();
}

class _CustomerRequestDetailScreenState extends State<CustomerRequestDetailScreen> {
  bool _offersLoading = true;
  final Set<String> _actingOffers = {};

  int _getStatusStepIndex(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 0;
      case ServiceRequestStatus.accepted:
        return 1;
      case ServiceRequestStatus.scheduled:
        return 2;
      case ServiceRequestStatus.inProgress:
        return 3;
      case ServiceRequestStatus.completed:
        return 4;
      case ServiceRequestStatus.cancelled:
        return -1;
    }
  }

  Future<bool> _hasConfirmedBooking(String requestId) async {
    final parsedId = int.tryParse(requestId);
    if (parsedId == null || parsedId <= 0) return false;
    try {
      final booking = await BookingRepository().getApiBookingByRequest(parsedId);
      return booking.acceptedAt != null && booking.acceptedAt!.isNotEmpty && booking.completedAt == null;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      await Provider.of<AppStateProvider>(context, listen: false).loadOffersForCustomerRequest(widget.requestId);
    } finally {
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  Future<void> _acceptOffer(String offerId) async {
    setState(() => _actingOffers.add(offerId));
    try {
      await Provider.of<AppStateProvider>(context, listen: false).acceptCustomerOffer(offerId, widget.requestId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول العرض وتأكيد الحجز بنجاح.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actingOffers.remove(offerId));
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    setState(() => _actingOffers.add(offerId));
    try {
      await Provider.of<AppStateProvider>(context, listen: false).rejectCustomerOffer(offerId, widget.requestId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض العرض.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _actingOffers.remove(offerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final request = appState.customerRequests.firstWhere((r) => r.id == widget.requestId, orElse: () => appState.customerRequests.first);
    final currentStep = _getStatusStepIndex(request.status);
    final offers = appState.customerOffers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('طلب #${request.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(request.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), StatusBadge.fromRequestStatus(request.status)]),
              const SizedBox(height: 6),
              Text('تاريخ الطلب: ${request.createdAt}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
              const Divider(height: 24),
              if (request.status != ServiceRequestStatus.cancelled) ...[
                const Text('مراحل تنفيذ الطلب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                const SizedBox(height: 12),
                Row(children: [_buildStepItem('تم الطلب', 0, currentStep), _buildStepDivider(0, currentStep), _buildStepItem('تم القبول', 1, currentStep), _buildStepDivider(1, currentStep), _buildStepItem('مجدول', 2, currentStep), _buildStepDivider(2, currentStep), _buildStepItem('جاري العمل', 3, currentStep), _buildStepDivider(3, currentStep), _buildStepItem('مكتمل', 4, currentStep)]),
              ] else
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)), child: Text('تم إلغاء هذا الطلب. السبب: ${request.cancellationReason ?? "بواسطة العميل"}', style: const TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo', fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 16),
          if (request.status != ServiceRequestStatus.cancelled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('عروض الفنيين', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text('${offers.length}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'))]),
                const SizedBox(height: 6),
                const Text('قارن السعر والملاحظات ثم اختر عرضاً واحداً. قبول العرض ينشئ الحجز المؤكد على الخادم.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.4)),
                const SizedBox(height: 12),
                if (_offersLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                else if (offers.isEmpty)
                  const Text('لم تصل عروض من الفنيين بعد.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'))
                else
                  ...offers.map((offer) {
                    final acting = _actingOffers.contains(offer.id);
                    final pending = offer.status.toLowerCase() == 'pending';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(radius: 20, child: Text(offer.technicianName.isNotEmpty ? offer.technicianName.substring(0, 1) : 'ف')),
                          const SizedBox(width: 10),
                          Expanded(child: Text(offer.technicianName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo'))),
                          Text('${offer.proposedPrice.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo')),
                        ]),
                        if (offer.technicianNote.isNotEmpty) ...[const SizedBox(height: 8), Text(offer.technicianNote, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))],
                        const SizedBox(height: 7),
                        Text('حالة العرض: ${offer.status}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                        if (offer.expiresAt != null && offer.expiresAt!.isNotEmpty) Text('ينتهي: ${offer.expiresAt}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                        if (pending && request.status.toString().toLowerCase().contains('pending')) ...[
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: OutlinedButton(onPressed: acting ? null : () => _rejectOffer(offer.id), child: const Text('رفض', style: TextStyle(fontFamily: 'Cairo')))),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton(onPressed: acting ? null : () => _acceptOffer(offer.id), child: Text(acting ? '...' : 'قبول العرض', style: const TextStyle(fontFamily: 'Cairo')))),
                          ]),
                        ],
                      ]),
                    );
                  }),
              ]),
            ),
          const SizedBox(height: 16),
          if (request.technicianName != null) ...[
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Row(children: [
              CircleAvatar(radius: 26, backgroundImage: NetworkImage(request.technicianAvatar ?? '')), const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(request.technicianName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text(request.technicianPhone ?? '+20 10 9876 5432', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))])),
              if (request.status != ServiceRequestStatus.cancelled) ElevatedButton.icon(onPressed: () async { final tech = appState.technicians.firstWhere((t) => t.userId == request.technicianId, orElse: () => appState.technicians.first); final conv = await appState.startConversationWithTechnician(technician: tech, serviceNameAr: request.serviceNameAr, requestId: request.id); if (!context.mounted) return; Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv))); }, icon: const Icon(Icons.chat_bubble_rounded, size: 16), label: const Text('محادثة', style: TextStyle(fontFamily: 'Cairo'))),
            ])),
            const SizedBox(height: 16),
          ],
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('تفاصيل العطل والخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), const SizedBox(height: 10), Text(request.problemDescription, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Cairo')), const Divider(height: 24), Row(children: [const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text('الموعد المفضل: ${request.preferredDate} (${request.preferredTime})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo'))]),
          ])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('عنوان تقديم الخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), const SizedBox(height: 8), Text(request.address.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')), Text(request.address.fullAddressDescription, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('تفاصيل الفاتورة والحساب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), const SizedBox(height: 12), _buildPriceRow('رسوم الكشف والزيارة', '80.00 ج.م'), const SizedBox(height: 6), _buildPriceRow('أجور الفحص وخدمة الصيانة', '${((request.finalPrice ?? request.estimatedPriceMin) - 80).clamp(0, 9999).toInt()}.00 ج.م'), const Divider(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المبلغ الإجمالي المتوقع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text(request.finalPrice != null ? '${request.finalPrice!.toInt()} ج.م' : '${request.estimatedPriceMin.toInt()} - ${request.estimatedPriceMax.toInt()} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo'))])]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('خيارات السداد الإلكتروني والنقدي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), const SizedBox(height: 6), const Text('يمكن اختيار طريقة الدفع بعد تأكيد الحجز مع الفني.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo')), const SizedBox(height: 12), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.credit_card_rounded, size: 18), label: const Text('سداد التكلفة / اختيار طريقة الدفع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)), onPressed: () async { final hasBooking = await _hasConfirmedBooking(request.id); if (!context.mounted) return; if (!hasBooking) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السداد متاح بعد تأكيد الحجز مع الفني.'))); return; } Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: request))); })]),
          const SizedBox(height: 16),
          if (request.status == ServiceRequestStatus.completed) ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 14)), icon: const Icon(Icons.star_rounded, color: Colors.white), label: const Text('تقييم تجربة الخدمة', style: TextStyle(fontSize: 15, fontFamily: 'Cairo', fontWeight: FontWeight.bold)), onPressed: () => showDialog(context: context, builder: (_) => ReviewDialog(requestId: request.id, technicianId: request.technicianId ?? '', technicianName: request.technicianName ?? 'فني الصيانة', serviceNameAr: request.serviceNameAr))),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildStepItem(String title, int stepIdx, int currentStep) { final isDone = currentStep >= stepIdx; final isCurrent = currentStep == stepIdx; return Expanded(child: Column(children: [Container(width: 24, height: 24, decoration: BoxDecoration(color: isDone ? AppColors.primary : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDone ? AppColors.primary : AppColors.border, width: 2)), child: Center(child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${stepIdx + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)))), const SizedBox(height: 4), Text(title, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, color: isDone ? AppColors.primaryDark : AppColors.textMuted, fontFamily: 'Cairo'))])); }
  Widget _buildStepDivider(int stepIdx, int currentStep) => Container(width: 16, height: 2, color: currentStep > stepIdx ? AppColors.primary : AppColors.border, margin: const EdgeInsets.only(bottom: 16));
  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 12, color: isDiscount ? AppColors.successDark : AppColors.textSecondary, fontFamily: 'Cairo')), Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDiscount ? AppColors.successDark : AppColors.textPrimary, fontFamily: 'Cairo'))]);
}
