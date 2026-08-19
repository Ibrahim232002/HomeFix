import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/service_request_model.dart';
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

  List<ServiceRequestModel> _filterRequests(
      List<ServiceRequestModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1: // Pending
        return all.where((r) => r.status == ServiceRequestStatus.pending).toList();
      case 2: // In Progress / Accepted / Scheduled
        return all
            .where((r) =>
                r.status == ServiceRequestStatus.accepted ||
                r.status == ServiceRequestStatus.scheduled ||
                r.status == ServiceRequestStatus.inProgress)
            .toList();
      case 3: // Completed
        return all.where((r) => r.status == ServiceRequestStatus.completed).toList();
      case 4: // Cancelled
        return all.where((r) => r.status == ServiceRequestStatus.cancelled).toList();
      default:
        return all;
    }
  }

  Future<void> _showCancelDialog(BuildContext context, ServiceRequestModel request) async {
    final reasonController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          bool cancelling = false;
          String? errorMessage;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (ctx, setDialogState) => AlertDialog(
                title: const Text('إلغاء طلب الخدمة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('هل أنت متأكد من رغبتك في إلغاء الطلب #${request.id}؟'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      enabled: !cancelling,
                      decoration: InputDecoration(
                        labelText: 'سبب الإلغاء (اختياري)',
                        hintText: 'مثال: تم حل المشكلة، تغيير الموعد...',
                        errorText: errorMessage,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: cancelling ? null : () => Navigator.pop(ctx),
                    child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: cancelling
                        ? null
                        : () async {
                            setDialogState(() {
                              cancelling = true;
                              errorMessage = null;
                            });
                            try {
                              await Provider.of<AppStateProvider>(context, listen: false).cancelRequest(
                                request.id,
                                reasonController.text.trim().isNotEmpty
                                    ? reasonController.text.trim()
                                    : 'إلغاء بواسطة العميل',
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
                              );
                            } catch (e) {
                              if (!ctx.mounted) return;
                              setDialogState(() {
                                cancelling = false;
                                errorMessage = e.toString().replaceFirst('Exception: ', '');
                              });
                            }
                          },
                    child: cancelling
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('تأكيد الإلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      reasonController.dispose();
    }
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
          final requests = _filterRequests(appState.customerRequests, tabIndex);

          if (requests.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_rounded,
              title: 'لا توجد طلبات في هذا القسم',
              description: 'يمكنك تصفح خدمات الصيانة المتنوعة وتقديم طلبك في أي وقت.',
              actionText: 'طلب خدمة جديدة',
              onAction: () {
                if (appState.services.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateRequestScreen(initialService: appState.services.first),
                    ),
                  );
                }
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#${req.id}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          StatusBadge.fromRequestStatus(req.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        req.serviceNameAr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.problemDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'Cairo',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              '${req.preferredDate} (${req.preferredTime})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                            ),
                            const Spacer(),
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                req.address.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (req.technicianName != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(req.technicianAvatar ?? ''),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.technicianName!,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                                  ),
                                  const Text(
                                    'الفني المخصص لتنفيذ الطلب',
                                    style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                            ),
                            if (req.status != ServiceRequestStatus.cancelled)
                              IconButton(
                                icon: const Icon(Icons.chat_outlined, color: AppColors.primary, size: 20),
                                onPressed: () async {
                                  final tech = appState.technicians.firstWhere(
                                    (t) => t.userId == req.technicianId,
                                    orElse: () => appState.technicians.first,
                                  );
                                  final conv = await appState.startConversationWithTechnician(
                                    technician: tech,
                                    serviceNameAr: req.serviceNameAr,
                                    requestId: req.id,
                                  );
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(conversation: conv),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'التكلفة التقديرية',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                              ),
                              Text(
                                req.finalPrice != null
                                    ? '${req.finalPrice!.toInt()} ج.م'
                                    : '${req.estimatedPriceMin.toInt()} - ${req.estimatedPriceMax.toInt()} ج.م',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (req.status == ServiceRequestStatus.pending)
                                TextButton(
                                  onPressed: () => _showCancelDialog(context, req),
                                  child: const Text(
                                    'إلغاء الطلب',
                                    style: TextStyle(color: AppColors.error, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (req.status == ServiceRequestStatus.completed)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF59E0B),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                                  label: const Text('تقييم الفني', style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ReviewDialog(
                                        requestId: req.id,
                                        technicianId: req.technicianId ?? '',
                                        technicianName: req.technicianName ?? 'فني الصيانة',
                                        serviceNameAr: req.serviceNameAr,
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerRequestDetailScreen(requestId: req.id),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'تفاصيل الطلب',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                                ),
                              ),
                            ],
                          ),
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
