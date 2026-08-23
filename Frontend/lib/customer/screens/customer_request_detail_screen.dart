import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_request_model.dart';
import '../../models/booking_model.dart';
import '../../models/api_dtos.dart';
import '../../models/inspection_model.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/service_repository.dart';
import '../../repositories/inspection_repository.dart';
import '../../common/screens/chat_detail_screen.dart';
import '../../common/widgets/review_dialog.dart';
import '../../common/widgets/booking_verification_dialog.dart';
import 'customer_payment_screen.dart';

class CustomerRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const CustomerRequestDetailScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  State<CustomerRequestDetailScreen> createState() => _CustomerRequestDetailScreenState();
}

class _CustomerRequestDetailScreenState extends State<CustomerRequestDetailScreen> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  final InspectionRepository _inspectionRepository = InspectionRepository();

  bool _requestLoading = true;
  bool _offersLoading = true;
  bool _bookingLoading = true;
  bool _completionActionLoading = false;
  String? _requestError;
  String? _offersError;
  ServiceRequestModel? _request;
  BookingModel? _booking;
  ServicePricingDto? _pricing;
  InspectionModel? _inspection;
  final Set<String> _actingOffers = {};

  int _getStatusStepIndex(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
      case ServiceRequestStatus.open:
      case ServiceRequestStatus.offerPending:
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

  @override
  void initState() {
    super.initState();
    _loadRequest();
    _loadOffers();
    _loadBooking();
  }

  String _errorMessage(Object error) => error.toString().replaceFirst('Exception: ', '');

  Future<void> _loadRequest() async {
    if (mounted) setState(() { _requestLoading = true; _requestError = null; });
    try {
      final request = await Provider.of<AppStateProvider>(context, listen: false).loadCustomerRequestById(widget.requestId);
      if (!mounted) return;
      if (request == null) {
        setState(() { _request = null; _requestLoading = false; });
        return;
      }
      setState(() { _request = request; _requestLoading = false; });
      await Future.wait([_loadPricing(request), _loadInspection(request)]);
    } catch (error) {
      if (!mounted) return;
      setState(() { _requestLoading = false; _requestError = _errorMessage(error); });
    }
  }

  Future<void> _loadPricing(ServiceRequestModel request) async {
    final serviceId = int.tryParse(request.serviceId);
    if (serviceId == null || serviceId <= 0) return;
    try {
      ServicePricingDto? pricing;
      final cityId = request.address.cityId;
      if (cityId != null && cityId > 0) {
        pricing = await _serviceRepository.getServicePricing(serviceId: serviceId, cityId: cityId);
      } else {
        final candidates = await _serviceRepository.getServicePricingsByService(serviceId);
        for (final candidate in candidates) {
          if (candidate.isActive && candidate.cityId == null) {
            pricing = candidate;
            break;
          }
        }
      }
      if (mounted) setState(() => _pricing = pricing);
    } catch (_) {
      // Request.VisitFee remains authoritative if supplemental pricing lookup fails.
    }
  }

  Future<void> _loadInspection(ServiceRequestModel request) async {
    final id = int.tryParse(request.id);
    if (id == null || id <= 0) return;
    try {
      final inspection = await _inspectionRepository.getInspectionByRequest(id);
      if (mounted) setState(() => _inspection = inspection);
    } catch (_) {
      // Inspection is optional until an inspection workflow is present for this request.
    }
  }

  Future<void> _loadOffers() async {
    if (mounted) setState(() { _offersLoading = true; _offersError = null; });
    try {
      await Provider.of<AppStateProvider>(context, listen: false).loadOffersForCustomerRequest(widget.requestId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _offersError = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  Future<void> _loadBooking() async {
    if (mounted) setState(() => _bookingLoading = true);
    try {
      final booking = await Provider.of<AppStateProvider>(context, listen: false).loadBookingForRequest(widget.requestId);
      if (!mounted) return;
      setState(() => _booking = booking);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _bookingLoading = false);
    }
  }

  Future<bool> _hasConfirmedBooking(String requestId) async {
    final id = int.tryParse(requestId);
    if (id == null || id <= 0) return false;
    final booking = await BookingRepository().getBookingByRequest(requestId);
    return booking != null && booking.status.isActive;
  }

  Future<void> _acceptOffer(String offerId) async {
    setState(() => _actingOffers.add(offerId));
    try {
      await Provider.of<AppStateProvider>(context, listen: false).acceptCustomerOffer(offerId, widget.requestId);
      await _loadBooking();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول العرض وتأكيد الحجز بنجاح.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _actingOffers.remove(offerId));
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    setState(() => _actingOffers.add(offerId));
    try {
      await Provider.of<AppStateProvider>(context, listen: false).rejectCustomerOffer(offerId, widget.requestId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض العرض.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _actingOffers.remove(offerId));
    }
  }

  Future<void> _verifyJobCompletion() async {
    final booking = _booking;
    if (booking == null || booking.status != BookingStatus.awaitingCompletion) return;
    setState(() => _completionActionLoading = true);
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.requestJobCompletionCode(booking.id);
      if (!mounted) return;
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BookingVerificationDialog(
          title: 'تأكيد إتمام الخدمة',
          description: 'أدخل رمز التحقق المكون من 6 أرقام لتأكيد اكتمال الخدمة.',
          onVerify: (code) => provider.verifyJobCompletion(booking.id, code),
          onResend: () => provider.requestJobCompletionCode(booking.id),
        ),
      );
      if (!mounted) return;
      if (verified == true) {
        await _loadBooking();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد إتمام الخدمة بنجاح.')));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _completionActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final request = _request;

    if (_requestLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_requestError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 44),
          const SizedBox(height: 12),
          Text(_requestError!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadRequest, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo'))),
        ]))),
      );
    }
    if (request == null) {
      return Scaffold(backgroundColor: AppColors.background, appBar: AppBar(title: const Text('تفاصيل الطلب')), body: const Center(child: Text('لم يتم العثور على طلب الخدمة.', style: TextStyle(fontFamily: 'Cairo'))));
    }

    final currentStep = _getStatusStepIndex(request.status);
    final offers = appState.customerOffers;
    final visitFee = request.visitFee ?? _pricing?.visitFee;
    final inspectionFee = _inspection?.fee ?? _pricing?.inspectionFee;
    final agreedPrice = _booking?.finalPrice ?? _booking?.agreedPrice;
    final hasRange = request.estimatedPriceMin != null || request.estimatedPriceMax != null;
    final totalLabel = agreedPrice != null
        ? '${agreedPrice.toInt()} ج.م'
        : hasRange
            ? '${request.estimatedPriceMin != null ? request.estimatedPriceMin!.toInt() : '—'} - ${request.estimatedPriceMax != null ? request.estimatedPriceMax!.toInt() : '—'} ج.م'
            : 'السعر حسب المعاينة';

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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(request.serviceNameAr, maxLines: 2, softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo'))),
                StatusBadge.fromRequestStatus(request.status),
              ]),
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
          if (request.status == ServiceRequestStatus.open || request.status == ServiceRequestStatus.offerPending || request.status == ServiceRequestStatus.accepted)
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
                else if (_offersError != null)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_offersError!, style: const TextStyle(fontSize: 12, color: AppColors.error, fontFamily: 'Cairo')), const SizedBox(height: 8), OutlinedButton.icon(onPressed: _loadOffers, icon: const Icon(Icons.refresh, size: 16), label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')))])
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
                        Row(children: [CircleAvatar(radius: 20, child: Text(offer.technicianName.isNotEmpty ? offer.technicianName.substring(0, 1) : 'ف')), const SizedBox(width: 10), Expanded(child: Text(offer.technicianName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo'))), Text('${offer.proposedPrice.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo'))]),
                        if (offer.technicianNote.isNotEmpty) ...[const SizedBox(height: 8), Text(offer.technicianNote, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))],
                        const SizedBox(height: 7),
                        Text('حالة العرض: ${offer.status}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                        if (offer.expiresAt != null && offer.expiresAt!.isNotEmpty) Text('ينتهي: ${offer.expiresAt}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                        if (pending && (request.status == ServiceRequestStatus.open || request.status == ServiceRequestStatus.offerPending)) ...[
                          const SizedBox(height: 10),
                          Row(children: [Expanded(child: OutlinedButton(onPressed: acting ? null : () => _rejectOffer(offer.id), child: const Text('رفض', style: TextStyle(fontFamily: 'Cairo')))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: acting ? null : () => _acceptOffer(offer.id), child: Text(acting ? '...' : 'قبول العرض', style: const TextStyle(fontFamily: 'Cairo'))))]),
                        ],
                      ]),
                    );
                  }),
              ]),
            ),
          const SizedBox(height: 16),
          if (request.technicianName != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                CircleAvatar(radius: 26, backgroundImage: NetworkImage(request.technicianAvatar ?? '')),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(request.technicianName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text(request.technicianPhone ?? '+20 10 9876 5432', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'))])),
                if (request.status != ServiceRequestStatus.cancelled)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final candidates = appState.technicians.where((t) => t.userId == request.technicianId).toList();
                      if (candidates.isEmpty) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بيانات الفني غير متاحة حالياً.')));
                        return;
                      }
                      final conv = await appState.startConversationWithTechnician(technician: candidates.first, serviceNameAr: request.serviceNameAr, requestId: request.id);
                      if (!context.mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv)));
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: const Text('محادثة', style: TextStyle(fontFamily: 'Cairo')),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('تفاصيل العطل والخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              const SizedBox(height: 10),
              Text(request.problemDescription, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Cairo')),
              if (request.files.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('الصور المرفقة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                SizedBox(height: 80, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: request.files.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) { final f = request.files[index]; return ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(f.url, width: 80, height: 80, fit: BoxFit.cover)); })),
              ],
              const Divider(height: 24),
              Row(children: [const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('الموعد المفضل: ${request.preferredDate} (${request.preferredTime})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')))]),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [Icon(Icons.location_pin, color: AppColors.primary, size: 18), SizedBox(width: 6), Text('عنوان تقديم الخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo'))]),
              const SizedBox(height: 8),
              Text(request.address.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              const SizedBox(height: 2),
              Text(request.address.fullAddressDescription, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
            ]),
          ),
          const SizedBox(height: 16),
          if (!_bookingLoading && _booking != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('حالة الحجز الفعلية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), StatusBadge.fromBookingStatus(_booking!.status)]),
                const SizedBox(height: 8),
                Text(_booking!.status.displayNameAr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                if (_booking!.status == BookingStatus.awaitingCompletion) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(onPressed: _completionActionLoading ? null : _verifyJobCompletion, icon: _completionActionLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.verified_rounded, size: 18), label: Text(_completionActionLoading ? 'جاري تجهيز رمز التحقق...' : 'تأكيد إتمام الخدمة', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
                ],
              ]),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('تفاصيل الفاتورة والحساب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              if (visitFee != null) _buildPriceRow(label: 'رسوم الزيارة', value: '${visitFee.toInt()} ج.م'),
              if (inspectionFee != null) ...[const SizedBox(height: 6), _buildPriceRow(label: 'رسوم المعاينة', value: '${inspectionFee.toInt()} ج.م')],
              if (agreedPrice != null) ...[const SizedBox(height: 6), _buildPriceRow(label: 'السعر المتفق عليه', value: '${agreedPrice.toInt()} ج.م')],
              if (visitFee == null && inspectionFee == null && agreedPrice == null && !hasRange) const Text('لا يوجد سعر نهائي أو نطاق سعر متاح بعد.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo')),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المبلغ الإجمالي المتوقع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')), Text(totalLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark, fontFamily: 'Cairo'))]),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('خيارات السداد الإلكتروني والنقدي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
              const SizedBox(height: 6),
              const Text('يمكن اختيار طريقة الدفع بعد تأكيد الحجز مع الفني.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.credit_card_rounded, size: 18),
                label: const Text('سداد التكلفة / اختيار طريقة الدفع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () async {
                  try {
                    final hasBooking = await _hasConfirmedBooking(request.id);
                    if (!context.mounted) return;
                    if (!hasBooking) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السداد متاح بعد تأكيد الحجز مع الفني.')));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: request)));
                  } catch (error) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          if (_booking?.status == BookingStatus.completed)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 14)),
              icon: const Icon(Icons.star_rounded, color: Colors.white),
              label: const Text('تقييم تجربة الخدمة', style: TextStyle(fontSize: 15, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onPressed: () => showDialog(context: context, builder: (_) => ReviewDialog(requestId: request.id, technicianId: request.technicianId ?? '', technicianName: request.technicianName ?? 'فني الصيانة', serviceNameAr: request.serviceNameAr)),
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildStepItem(String title, int stepIdx, int currentStep) {
    final isDone = currentStep >= stepIdx;
    final isCurrent = currentStep == stepIdx;
    return Expanded(child: Column(children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(color: isDone ? AppColors.primary : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDone ? AppColors.primary : AppColors.border, width: 2)), child: Center(child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${stepIdx + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 4),
      Text(title, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, color: isDone ? AppColors.primaryDark : AppColors.textMuted, fontFamily: 'Cairo')),
    ]));
  }

  Widget _buildStepDivider(int stepIdx, int currentStep) {
    return Container(width: 16, height: 2, color: currentStep > stepIdx ? AppColors.primary : AppColors.border, margin: const EdgeInsets.only(bottom: 16));
  }

  Widget _buildPriceRow({required String label, required String value, bool isDiscount = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: isDiscount ? AppColors.successDark : AppColors.textSecondary, fontFamily: 'Cairo')),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDiscount ? AppColors.successDark : AppColors.textPrimary, fontFamily: 'Cairo')),
    ]);
  }
}
