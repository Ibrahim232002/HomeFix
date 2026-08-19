import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_request_model.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/booking_repository.dart';
import '../../common/screens/chat_detail_screen.dart';
import '../../common/widgets/review_dialog.dart';
import 'customer_payment_screen.dart';

class CustomerRequestDetailScreen extends StatelessWidget {
  final String requestId;

  const CustomerRequestDetailScreen({Key? key, required this.requestId}) : super(key: key);

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
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final request = appState.customerRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => appState.customerRequests.first,
    );

    final currentStep = _getStatusStepIndex(request.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('طلب #${request.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      Text(request.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                      StatusBadge.fromRequestStatus(request.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('تاريخ الطلب: ${request.createdAt}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
                  const Divider(height: 24),
                  if (request.status != ServiceRequestStatus.cancelled) ...[
                    const Text('مراحل تنفيذ الطلب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStepItem('تم الطلب', 0, currentStep),
                        _buildStepDivider(0, currentStep),
                        _buildStepItem('تم القبول', 1, currentStep),
                        _buildStepDivider(1, currentStep),
                        _buildStepItem('مجدول', 2, currentStep),
                        _buildStepDivider(2, currentStep),
                        _buildStepItem('جاري العمل', 3, currentStep),
                        _buildStepDivider(3, currentStep),
                        _buildStepItem('مكتمل', 4, currentStep),
                      ],
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.errorDark, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('تم إلغاء هذا الطلب. السبب: ${request.cancellationReason ?? "بواسطة العميل"}', style: const TextStyle(fontSize: 12, color: AppColors.errorDark, fontFamily: 'Cairo', fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (request.technicianName != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الفني المختص المعتمد', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(radius: 26, backgroundImage: NetworkImage(request.technicianAvatar ?? '')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.technicianName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                              Text(request.technicianPhone ?? '+20 10 9876 5432', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primarySurface, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: const Text('محادثة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                          onPressed: () async {
                            final tech = appState.technicians.firstWhere((t) => t.userId == request.technicianId, orElse: () => appState.technicians.first);
                            final conv = await appState.startConversationWithTechnician(technician: tech, serviceNameAr: request.serviceNameAr, requestId: request.id);
                            if (!context.mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv)));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تفاصيل العطل والخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                  const SizedBox(height: 10),
                  Text(request.problemDescription, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Cairo')),
                  if (request.files.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('الصور المرفقة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: request.files.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final f = request.files[index];
                          return ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(f.url, width: 80, height: 80, fit: BoxFit.cover));
                        },
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('الموعد المفضل: ${request.preferredDate} (${request.preferredTime})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_pin, color: AppColors.primary, size: 18),
                      SizedBox(width: 6),
                      Text('عنوان تقديم الخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request.address.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                  const SizedBox(height: 2),
                  Text(request.address.fullAddressDescription, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تفاصيل الفاتورة والحساب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                  const SizedBox(height: 12),
                  _buildPriceRow('رسوم الكشف والزيارة', '80.00 ج.م'),
                  const SizedBox(height: 6),
                  _buildPriceRow('أجور الفحص وخدمة الصيانة', '${((request.finalPrice ?? request.estimatedPriceMin) - 80).clamp(0, 9999).toInt()}.00 ج.م'),
                  if (request.notes != null && request.notes!.contains('خصم')) ...[
                    const SizedBox(height: 6),
                    _buildPriceRow('خصم كود الترويج', '-50.00 ج.م', isDiscount: true),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المبلغ الإجمالي المتوقع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                      Text(request.finalPrice != null ? '${request.finalPrice!.toInt()} ج.م' : '${request.estimatedPriceMin.toInt()} - ${request.estimatedPriceMax.toInt()} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.payment_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('خيارات السداد الإلكتروني والنقدي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('يمكن اختيار طريقة الدفع بعد تأكيد الحجز مع الفني.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.4)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(Icons.credit_card_rounded, size: 18),
                    label: const Text('سداد التكلفة / اختيار طريقة الدفع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () async {
                      final hasBooking = await _hasConfirmedBooking(request.id);
                      if (!context.mounted) return;
                      if (!hasBooking) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السداد متاح بعد تأكيد الحجز مع الفني.')));
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: request)));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (request.status == ServiceRequestStatus.completed)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text('تقييم تجربة الخدمة', style: TextStyle(fontSize: 15, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ReviewDialog(
                      requestId: request.id,
                      technicianId: request.technicianId ?? '',
                      technicianName: request.technicianName ?? 'فني الصيانة',
                      serviceNameAr: request.serviceNameAr,
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String title, int stepIdx, int currentStep) {
    final isDone = currentStep >= stepIdx;
    final isCurrent = currentStep == stepIdx;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: isDone ? AppColors.primary : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDone ? AppColors.primary : AppColors.border, width: 2)),
            child: Center(child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${stepIdx + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, color: isDone ? AppColors.primaryDark : AppColors.textMuted, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildStepDivider(int stepIdx, int currentStep) {
    final isDone = currentStep > stepIdx;
    return Container(width: 16, height: 2, color: isDone ? AppColors.primary : AppColors.border, margin: const EdgeInsets.only(bottom: 16));
  }

  Widget _buildPriceRow(String label, String amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: isDiscount ? AppColors.successDark : AppColors.textSecondary, fontFamily: 'Cairo')),
        Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDiscount ? AppColors.successDark : AppColors.textPrimary, fontFamily: 'Cairo')),
      ],
    );
  }
}
