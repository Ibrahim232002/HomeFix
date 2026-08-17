import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'create_request_screen.dart';
import 'customer_offers_screen.dart';
import 'customer_request_detail_screen.dart';

class CustomerRequestsScreen extends StatefulWidget {
  const CustomerRequestsScreen({super.key});

  @override
  State<CustomerRequestsScreen> createState() => _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends State<CustomerRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<ServiceRequestModel> _filter(List<ServiceRequestModel> all, int index) {
    switch (index) {
      case 1:
        return all.where((r) => r.status == ServiceRequestStatus.pending).toList();
      case 2:
        return all.where((r) => r.status == ServiceRequestStatus.accepted ||
            r.status == ServiceRequestStatus.scheduled ||
            r.status == ServiceRequestStatus.inProgress).toList();
      case 3:
        return all.where((r) => r.status == ServiceRequestStatus.completed).toList();
      case 4:
        return all.where((r) => r.status == ServiceRequestStatus.cancelled).toList();
      default:
        return all;
    }
  }

  Future<void> _openOffers(BuildContext context, ServiceRequestModel request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerOffersScreen(requestId: request.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلبات الصيانة'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
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
        controller: _tabs,
        children: List.generate(5, (index) {
          final requests = _filter(appState.customerRequests, index);
          if (requests.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'لا توجد طلبات في هذا القسم',
              description: 'أنشئ طلب صيانة جديداً لبدء رحلة الخدمة.',
              actionText: 'طلب خدمة جديدة',
              onAction: appState.services.isEmpty
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateRequestScreen(initialService: appState.services.first),
                        ),
                      ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final request = requests[i];
              final pending = request.status == ServiceRequestStatus.pending;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#${request.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          StatusBadge.fromRequestStatus(request.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(request.serviceNameAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(request.problemDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Text('${request.preferredDate} (${request.preferredTime})'),
                      const SizedBox(height: 6),
                      Text(
                        request.finalPrice != null
                            ? '${request.finalPrice!.toStringAsFixed(2)} ج.م'
                            : request.estimatedPriceMax > 0
                                ? '${request.estimatedPriceMin.toStringAsFixed(0)} - ${request.estimatedPriceMax.toStringAsFixed(0)} ج.م'
                                : 'السعر يحدده عرض الفني',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerRequestDetailScreen(requestId: request.id),
                                ),
                              ),
                              child: const Text('التفاصيل'),
                            ),
                          ),
                          if (pending) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openOffers(context, request),
                                icon: const Icon(Icons.local_offer_outlined),
                                label: const Text('العروض'),
                              ),
                            ),
                          ],
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
