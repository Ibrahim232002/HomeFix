import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/service_request_model.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_request_detail_screen.dart';
import 'create_request_screen.dart';
import '../../common/screens/chat_detail_screen.dart';
import '../../common/widgets/review_dialog.dart';

class CustomerRequestsScreen extends StatefulWidget {
  const CustomerRequestsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRequestsScreen> createState() => _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends State<CustomerRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BookingModel? _bookingForRequest(AppStateProvider appState, ServiceRequestModel request) {
    for (final booking in appState.bookings) {
      if (booking.requestId == request.id) return booking;
    }
    return null;
  }

  List<ServiceRequestModel> _filterRequests(List<ServiceRequestModel> all, AppStateProvider appState, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return all.where((r) =>
          r.status == ServiceRequestStatus.pending ||
          r.status == ServiceRequestStatus.open ||
          r.status == ServiceRequestStatus.offerPending).toList();
      case 2:
        return all.where((r) {
          final booking = _bookingForRequest(appState, r);
          return r.status == ServiceRequestStatus.accepted ||
              r.status == ServiceRequestStatus.scheduled ||
              r.status == ServiceRequestStatus.inProgress ||
              (booking != null && {
                BookingStatus.upcoming,
                BookingStatus.technicianOnTheWay,
                BookingStatus.arrived,
                BookingStatus.inProgress,
                BookingStatus.awaitingCompletion,
              }.contains(booking.status));
        }).toList();
      case 3:
        return all.where((r) {
          final booking = _bookingForRequest(appState, r);
          return r.status == ServiceRequestStatus.completed || booking?.status == BookingStatus.completed;
        }).toList();
      case 4:
        return all.where((r) {
          final booking = _bookingForRequest(appState, r);
          return r.status == ServiceRequestStatus.cancelled || booking?.status == BookingStatus.cancelled;
        }).toList();
      default:
        return all;
    }
  }

  Future<void> _showCancelDialog(BuildContext context, ServiceRequestModel request) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _CancelRequestDialog(requestId: request.id),
    );

    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سجل طلبات الصيانة'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'قيد المراجعة'),
            Tab(text: 'جاري التنفيذ'),
            Tab(text: 'المكتملة'),
            Tab(text: 'الملغاة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (tabIndex) {
          final requests = _filterRequests(appState.customerRequests, appState, tabIndex);

          if (requests.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_rounded,
              title: 'لا توجد طلبات في هذا القسم',
              description: 'يمكنك تصفح خدمات الصيانة المتنوعة وتقديم طلبك في أي وقت.',
              actionText: 'طلب خدمة جديدة',
              onAction: () {
                if (appState.services.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CreateRequestScreen(initialService: appState.services.first),
                  ));
                }
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final booking = _bookingForRequest(appState, req);
              final requestCompleted = req.status == ServiceRequestStatus.completed || booking?.status == BookingStatus.completed;
              final effectiveStatusBadge = booking != null
                  ? StatusBadge.fromBookingStatus(booking.status)
                  : StatusBadge.fromRequestStatus(req.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text('#${req.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                          ]),
                          effectiveStatusBadge,
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(req.serviceNameAr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                      if (req.categoryNameAr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(req.categoryNameAr, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                      ],
                      const SizedBox(height: 4),
                      Text(req.problemDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.4)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text('${req.preferredDate} (${req.preferredTime})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                          const Spacer(),
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Flexible(child: Text(req.address.title.isNotEmpty ? req.address.title : 'العنوان المحدد', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'))),
                        ]),
                      ),
                      if (req.technicianName != null) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          CircleAvatar(radius: 16, backgroundImage: NetworkImage(req.technicianAvatar ?? '')),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(req.technicianName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                            const Text('الفني المخصص لتنفيذ الطلب', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'Cairo')),
                          ])),
                          if (req.status != ServiceRequestStatus.cancelled)
                            IconButton(
                              icon: const Icon(Icons.chat_outlined, color: AppColors.primary, size: 20),
                              onPressed: () async {
                                final tech = appState.technicians.firstWhere((t) => t.userId == req.technicianId, orElse: () => appState.technicians.first);
                                final conv = await appState.startConversationWithTechnician(technician: tech, serviceNameAr: req.serviceNameAr, requestId: req.id);
                                if (!context.mounted) return;
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv)));
                              },
                            ),
                        ]),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('رسوم الزيارة', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                            Text('${req.estimatedPriceMin.toInt()} ج.م', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontFamily: 'Cairo')),
                          ]),
                          Row(children: [
                            if (req.status == ServiceRequestStatus.open)
                              TextButton(
                                onPressed: () => _showCancelDialog(context, req),
                                child: const Text('إلغاء الطلب', style: TextStyle(color: AppColors.error, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              ),
                            if (requestCompleted)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                icon: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                                label: const Text('تقييم الفني', style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                                onPressed: () => showDialog(context: context, builder: (_) => ReviewDialog(requestId: req.id, technicianId: req.technicianId ?? '', technicianName: req.technicianName ?? 'فني الصيانة', serviceNameAr: req.serviceNameAr)),
                              ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerRequestDetailScreen(requestId: req.id))),
                              child: const Text('تفاصيل الطلب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _CancelRequestDialog extends StatefulWidget {
  final String requestId;

  const _CancelRequestDialog({required this.requestId});

  @override
  State<_CancelRequestDialog> createState() => _CancelRequestDialogState();
}

class _CancelRequestDialogState extends State<_CancelRequestDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _cancelling = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_cancelling) return;
    setState(() {
      _cancelling = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AppStateProvider>(context, listen: false).cancelRequest(
        widget.requestId,
        _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : 'إلغاء بواسطة العميل',
      );
      if (!mounted) return;
      Navigator.pop(context, 'cancelled');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cancelling = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إلغاء طلب الخدمة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رغبتك في إلغاء الطلب #${widget.requestId}?'),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              enabled: !_cancelling,
              decoration: InputDecoration(
                labelText: 'سبب الإلغاء (اختياري)',
                hintText: 'مثال: تم حل المشكلة، تغيير الموعد...',
                errorText: _errorMessage,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancelling ? null : () => Navigator.pop(context),
            child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: _cancelling ? null : _confirm,
            child: _cancelling
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تأكيد الإلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}