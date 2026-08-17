import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/review_dialog.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_booking_screen.dart';
import 'customer_offers_screen.dart';
import 'customer_payment_screen.dart';

class CustomerRequestDetailScreen extends StatelessWidget {
  final String requestId;

  const CustomerRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    ServiceRequestModel? request;
    for (final item in appState.customerRequests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: Text('طلب #$requestId')),
        body: const Center(child: Text('لم يتم العثور على الطلب.')),
      );
    }

    final currentRequest = request;
    final hasBooking = currentRequest.status == ServiceRequestStatus.accepted ||
        currentRequest.status == ServiceRequestStatus.scheduled ||
        currentRequest.status == ServiceRequestStatus.inProgress ||
        currentRequest.status == ServiceRequestStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('طلب #${currentRequest.id}')),
      body: RefreshIndicator(
        onRefresh: appState.refreshAuthenticatedData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(currentRequest.serviceNameAr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                StatusBadge.fromRequestStatus(currentRequest.status),
              ]),
              const SizedBox(height: 8),
              Text('تاريخ الطلب: ${currentRequest.createdAt}'),
            ])),
            const SizedBox(height: 12),
            _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('تفاصيل الخدمة', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(currentRequest.problemDescription),
              const SizedBox(height: 12),
              Text('الموعد المطلوب: ${currentRequest.preferredDate} (${currentRequest.preferredTime})'),
            ])),
            const SizedBox(height: 12),
            _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('العنوان', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(currentRequest.address.fullAddressDescription),
            ])),
            const SizedBox(height: 12),
            _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('التسعير', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(currentRequest.finalPrice != null
                  ? '${currentRequest.finalPrice!.toStringAsFixed(2)} ج.م'
                  : currentRequest.estimatedPriceMin > 0
                      ? '${currentRequest.estimatedPriceMin.toStringAsFixed(2)} ج.م رسوم/سعر مرجعي'
                      : 'السعر النهائي يحدده عرض الفني.'),
              const SizedBox(height: 4),
              const Text('لا يتم اعتبار أي قيمة محسوبة محلياً مبلغاً نهائياً؛ السعر النهائي يعتمد على بيانات الخادم.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            const SizedBox(height: 12),
            if (currentRequest.status == ServiceRequestStatus.pending)
              _action(context, icon: Icons.local_offer_outlined, label: 'عرض عروض الفنيين', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOffersScreen(requestId: currentRequest.id)))),
            if (hasBooking)
              _action(context, icon: Icons.event_available_outlined, label: 'تفاصيل الحجز والتحقق', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerBookingScreen(requestId: currentRequest.id)))),
            if (currentRequest.status != ServiceRequestStatus.cancelled)
              _action(context, icon: Icons.payments_outlined, label: 'الدفع', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: currentRequest)))),
            if (currentRequest.status == ServiceRequestStatus.completed) ...[
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => ReviewDialog(requestId: currentRequest.id, technicianId: currentRequest.technicianId ?? '', technicianName: currentRequest.technicianName ?? 'فني الصيانة', serviceNameAr: currentRequest.serviceNameAr)),
                icon: const Icon(Icons.star_rounded),
                label: const Text('تقييم الخدمة'),
              ),
            ],
            const SizedBox(height: 12),
            if (currentRequest.files.isNotEmpty)
              _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('الملفات المرفقة', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentRequest.files.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(currentRequest.files[index].url, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 90, height: 90, child: Icon(Icons.insert_drive_file_outlined))),
                    ),
                  ),
                ),
              ])),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Card(child: Padding(padding: const EdgeInsets.all(16), child: child));

  Widget _action(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
      );
}
