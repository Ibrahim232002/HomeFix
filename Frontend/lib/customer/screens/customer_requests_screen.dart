import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
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

  List<ServiceRequestModel> _filter(List<ServiceRequestModel> requests, int index) {
    switch (index) {
      case 1:
        return requests.where((request) => request.status == ServiceRequestStatus.pending).toList();
      case 2:
        return requests
            .where((request) => {
                  ServiceRequestStatus.accepted,
                  ServiceRequestStatus.scheduled,
                  ServiceRequestStatus.inProgress,
                }.contains(request.status))
            .toList();
      case 3:
        return requests.where((request) => request.status == ServiceRequestStatus.completed).toList();
      case 4:
        return requests.where((request) => request.status == ServiceRequestStatus.cancelled).toList();
      default:
        return requests;
    }
  }

  HomeFixStatusTone _toneFor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return HomeFixStatusTone.warning;
      case ServiceRequestStatus.accepted:
      case ServiceRequestStatus.scheduled:
        return HomeFixStatusTone.info;
      case ServiceRequestStatus.inProgress:
        return HomeFixStatusTone.technician;
      case ServiceRequestStatus.completed:
        return HomeFixStatusTone.success;
      case ServiceRequestStatus.cancelled:
        return HomeFixStatusTone.error;
    }
  }

  Future<void> _refresh() async {
    await context.read<AppStateProvider>().refreshAuthenticatedData();
  }

  Future<void> _openCreateRequest() async {
    final state = context.read<AppStateProvider>();
    if (state.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد خدمات متاحة لإنشاء طلب جديد حالياً.')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateRequestScreen(initialService: state.services.first)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final padding = AppResponsive.pagePadding(context);
    final requests = _filter(state.customerRequests, _tabs.index);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلباتي'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'قيد المراجعة'),
            Tab(text: 'جارية'),
            Tab(text: 'مكتملة'),
            Tab(text: 'ملغاة'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateRequest,
        icon: const Icon(Icons.add_rounded),
        label: const Text('طلب جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AnimatedBuilder(
          animation: _tabs,
          builder: (context, _) {
            final filtered = _filter(state.customerRequests, _tabs.index);
            if (state.isLoading && state.customerRequests.isEmpty) {
              return ListView(
                padding: padding.add(const EdgeInsets.only(bottom: 120)),
                children: const [HomeFixSkeletonList(itemCount: 5)],
              );
            }

            if (filtered.isEmpty) {
              return ListView(
                padding: padding.add(const EdgeInsets.only(bottom: 120)),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.62,
                    child: HomeFixEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: _tabs.index == 0 ? 'لا توجد طلبات بعد' : 'لا توجد طلبات في هذا القسم',
                      message: _tabs.index == 0
                          ? 'ابدأ بطلب خدمة منزلية وستجد متابعة الطلب والعروض والحجز هنا.'
                          : 'جرّب تبويباً آخر أو أنشئ طلب خدمة جديداً.',
                      showRetry: state.errorMessage != null,
                      onRetry: _refresh,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding.add(const EdgeInsets.only(bottom: 120)),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDesignTokens.space3),
              itemBuilder: (context, index) {
                final request = filtered[index];
                final pending = request.status == ServiceRequestStatus.pending;
                return HomeFixCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(request.serviceNameAr, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: AppDesignTokens.space1),
                                Text('#${request.id}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          HomeFixStatusChip(
                            label: request.status.displayNameAr,
                            tone: _toneFor(request.status),
                            icon: Icons.circle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignTokens.space4),
                      _InfoRow(icon: Icons.location_on_outlined, text: request.address.fullAddressDescription),
                      const SizedBox(height: AppDesignTokens.space2),
                      _InfoRow(icon: Icons.schedule_outlined, text: '${request.preferredDate} · ${request.preferredTime}'),
                      const SizedBox(height: AppDesignTokens.space2),
                      _InfoRow(icon: Icons.notes_outlined, text: request.problemDescription, maxLines: 2),
                      const SizedBox(height: AppDesignTokens.space4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.finalPrice != null
                                  ? '${request.finalPrice!.toStringAsFixed(2)} ${_currencyFor(request)}'
                                  : request.estimatedPriceMax > 0
                                      ? '${request.estimatedPriceMin.toStringAsFixed(0)}–${request.estimatedPriceMax.toStringAsFixed(0)} ${_currencyFor(request)}'
                                      : 'السعر النهائي يحدده عرض الفني',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                          const SizedBox(width: AppDesignTokens.space2),
                          HomeFixButton(
                            label: 'التفاصيل',
                            icon: Icons.arrow_forward_rounded,
                            expanded: false,
                            variant: HomeFixButtonVariant.outline,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CustomerRequestDetailScreen(requestId: request.id)),
                            ),
                          ),
                        ],
                      ),
                      if (pending) ...[
                        const SizedBox(height: AppDesignTokens.space2),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CustomerOffersScreen(requestId: request.id)),
                            ),
                            icon: const Icon(Icons.local_offer_outlined),
                            label: const Text('مشاهدة عروض الفنيين'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _currencyFor(ServiceRequestModel request) => 'ج.م';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.maxLines = 1});

  final IconData icon;
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppDesignTokens.space2),
        Expanded(
          child: Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
