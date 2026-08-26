import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../services/app_state_provider.dart';
import 'technician_request_detail_screen.dart';

class TechnicianRequestsScreen extends StatelessWidget {
  const TechnicianRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final available = appState.availableTechRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الطلبات المتاحة في النطاق الجغرافي')),
      body: appState.isLoadingAvailableTechRequests
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : appState.availableTechRequestsError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text(
                          'تعذر تحميل الطلبات حالياً',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: appState.refreshAvailableTechnicianRequests,
                          child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ),
                )
              : available.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.near_me_disabled_rounded,
                      title: 'لا توجد طلبات صيانة متاحة حالياً',
                      description: 'طلبات العملاء المطابقة لخدماتك ومناطقك ستظهر هنا.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final req = available[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.technicianLight),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.technicianPrimary.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.technicianLight, borderRadius: BorderRadius.circular(8)),
                                      child: Text(req.categoryNameAr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.technicianPrimary, fontFamily: 'Cairo')),
                                    ),
                                    Text('#${req.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, fontFamily: 'Cairo')),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(req.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                                const SizedBox(height: 6),
                                Text(req.problemDescription, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo', height: 1.4)),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(12)),
                                  child: Column(children: [
                                    Row(children: [
                                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.technicianPrimary),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text('${req.address.city} - ${req.address.street} (${req.address.building})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'))),
                                    ]),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.technicianPrimary),
                                      const SizedBox(width: 6),
                                      Text('${req.preferredDate} (${req.preferredTime})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                                    ]),
                                  ]),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text('النطاق السعري للطلب', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo')),
                                      Text('${req.estimatedPriceMin?.toInt() ?? '—'} - ${req.estimatedPriceMax?.toInt() ?? '—'} ج.م', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.technicianDark, fontFamily: 'Cairo')),
                                    ]),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.technicianPrimary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                                      icon: const Icon(Icons.local_offer_outlined, size: 18),
                                      label: const Text('فتح وتقديم عرض', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (_) => TechnicianRequestDetailScreen(request: req)));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
