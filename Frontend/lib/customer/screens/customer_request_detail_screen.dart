import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/review_dialog.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_booking_screen.dart';
import 'customer_offers_screen.dart';
import 'customer_payment_screen.dart';

class CustomerRequestDetailScreen extends StatefulWidget {
  const CustomerRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<CustomerRequestDetailScreen> createState() => _CustomerRequestDetailScreenState();
}

class _CustomerRequestDetailScreenState extends State<CustomerRequestDetailScreen> {
  bool _refreshing = false;

  ServiceRequestModel? _findRequest(AppStateProvider state) {
    for (final request in state.customerRequests) {
      if (request.id == widget.requestId) return request;
    }
    return null;
  }

  Future<void> _retry() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await context.read<AppStateProvider>().refreshAuthenticatedData();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  HomeFixStatusTone _tone(ServiceRequestStatus status) => switch (status) {
        ServiceRequestStatus.pending => HomeFixStatusTone.warning,
        ServiceRequestStatus.accepted || ServiceRequestStatus.scheduled => HomeFixStatusTone.info,
        ServiceRequestStatus.inProgress => HomeFixStatusTone.technician,
        ServiceRequestStatus.completed => HomeFixStatusTone.success,
        ServiceRequestStatus.cancelled => HomeFixStatusTone.error,
      };

  IconData _statusIcon(ServiceRequestStatus status) => switch (status) {
        ServiceRequestStatus.pending => Icons.hourglass_top_rounded,
        ServiceRequestStatus.accepted => Icons.check_circle_outline_rounded,
        ServiceRequestStatus.scheduled => Icons.event_available_rounded,
        ServiceRequestStatus.inProgress => Icons.handyman_rounded,
        ServiceRequestStatus.completed => Icons.verified_rounded,
        ServiceRequestStatus.cancelled => Icons.cancel_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final request = _findRequest(state);

    if (request == null && state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('طلب #${widget.requestId}')),
        body: ListView(
          padding: AppResponsive.pagePadding(context),
          children: const [
            HomeFixSkeleton(height: 140),
            SizedBox(height: AppDesignTokens.space4),
            HomeFixSkeleton(height: 180),
            SizedBox(height: AppDesignTokens.space4),
            HomeFixSkeleton(height: 150),
          ],
        ),
      );
    }

    if (request == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('طلب #${widget.requestId}')),
        body: HomeFixErrorState(
          title: 'تعذر تحميل الطلب',
          message: state.errorMessage ?? 'لم يتم العثور على بيانات الطلب حالياً.',
          onRetry: _retry,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${request.id}'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _refreshing ? null : _retry,
            icon: _refreshing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _retry,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppResponsive.pagePadding(context).add(const EdgeInsets.only(bottom: AppDesignTokens.space8)),
          children: [
            _HeaderCard(request: request, tone: _tone(request.status), statusIcon: _statusIcon(request.status)),
            const SizedBox(height: AppDesignTokens.space4),
            _StatusTimeline(request: request),
            const SizedBox(height: AppDesignTokens.space4),
            _SectionCard(
              title: 'تفاصيل الخدمة',
              icon: Icons.home_repair_service_rounded,
              children: [
                _InfoRow(label: 'الخدمة', value: request.serviceNameAr),
                _InfoRow(label: 'الوصف', value: request.problemDescription),
                _InfoRow(label: 'الموعد المطلوب', value: '${request.preferredDate} · ${request.preferredTime}'),
              ],
            ),
            const SizedBox(height: AppDesignTokens.space4),
            _SectionCard(
              title: 'العنوان',
              icon: Icons.location_on_outlined,
              children: [_InfoRow(label: 'العنوان', value: request.address.fullAddressDescription)],
            ),
            const SizedBox(height: AppDesignTokens.space4),
            _SectionCard(
              title: 'السعر',
              icon: Icons.payments_outlined,
              children: [
                if (request.finalPrice != null)
                  Text(
                    '${request.finalPrice!.toStringAsFixed(2)} ج.م',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryDark),
                  )
                else if (request.estimatedPriceMax > 0)
                  Text(
                    '${request.estimatedPriceMin.toStringAsFixed(0)} – ${request.estimatedPriceMax.toStringAsFixed(0)} ج.م',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark),
                  )
                else
                  Text('السعر النهائي يحدده عرض الفني.', style: Theme.of(context).textTheme.bodyLarge),
                if (request.finalPrice == null) ...[
                  const SizedBox(height: AppDesignTokens.space2),
                  Text(
                    'القيمة المعروضة هنا من بيانات الخادم وليست حساباً محلياً نهائياً.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
            if (request.files.isNotEmpty) ...[
              const SizedBox(height: AppDesignTokens.space4),
              _AttachmentsCard(files: request.files),
            ],
            if (_showActions(request.status)) ...[
              const SizedBox(height: AppDesignTokens.space5),
              _Actions(request: request),
            ],
          ],
        ),
      ),
    );
  }

  bool _showActions(ServiceRequestStatus status) => status != ServiceRequestStatus.cancelled;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.request, required this.tone, required this.statusIcon});

  final ServiceRequestModel request;
  final HomeFixStatusTone tone;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
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
                    Text(request.serviceNameAr, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppDesignTokens.space1),
                    Text('تم إنشاء الطلب ${request.createdAt}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              HomeFixStatusChip(label: request.status.displayNameAr, tone: tone, icon: statusIcon),
            ],
          ),
          if (request.technicianName != null && request.technicianName!.trim().isNotEmpty) ...[
            const SizedBox(height: AppDesignTokens.space4),
            Container(
              padding: const EdgeInsets.all(AppDesignTokens.space3),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 22, child: Icon(Icons.person_outline_rounded)),
                  const SizedBox(width: AppDesignTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الفني', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(request.technicianName!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.request});

  final ServiceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final statuses = <ServiceRequestStatus>[
      ServiceRequestStatus.pending,
      ServiceRequestStatus.accepted,
      ServiceRequestStatus.scheduled,
      ServiceRequestStatus.inProgress,
      ServiceRequestStatus.completed,
    ];
    final currentIndex = request.status == ServiceRequestStatus.cancelled ? -1 : statuses.indexOf(request.status);

    return HomeFixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('حالة الطلب', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDesignTokens.space4),
          if (request.status == ServiceRequestStatus.cancelled)
            const _TimelineRow(label: 'تم إلغاء الطلب', icon: Icons.cancel_outlined, tone: HomeFixStatusTone.error, active: true)
          else
            for (var index = 0; index < statuses.length; index++)
              _TimelineRow(
                label: statuses[index].displayNameAr,
                icon: Icons.circle,
                tone: index <= currentIndex ? HomeFixStatusTone.info : HomeFixStatusTone.neutral,
                active: index == currentIndex,
                showConnector: index != statuses.length - 1,
              ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.icon, required this.tone, required this.active, this.showConnector = false});

  final String label;
  final IconData icon;
  final HomeFixStatusTone tone;
  final bool active;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      HomeFixStatusTone.info => AppColors.primary,
      HomeFixStatusTone.error => AppColors.error,
      _ => AppColors.border,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: active ? color : AppColors.surface, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                child: SizedBox(width: 16, height: 16, child: active ? Icon(Icons.check_rounded, size: 11, color: color) : null),
              ),
              if (showConnector) Container(width: 2, height: 28, color: color.withValues(alpha: 0.35)),
            ],
          ),
        ),
        const SizedBox(width: AppDesignTokens.space3),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: AppDesignTokens.space3),
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.textPrimary : AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return HomeFixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: Padding(padding: const EdgeInsets.all(AppDesignTokens.space2), child: Icon(icon, size: 19, color: AppColors.primaryDark)),
              ),
              const SizedBox(width: AppDesignTokens.space2),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space4),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppDesignTokens.space1),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({required this.files});

  final List<ServiceRequestFileModel> files;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'المرفقات',
      icon: Icons.attach_file_rounded,
      children: [
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppDesignTokens.space2),
            itemBuilder: (_, index) {
              final file = files[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                child: Image.network(
                  file.url,
                  width: 94,
                  height: 94,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 94, height: 94, color: AppColors.borderLight, child: const Icon(Icons.insert_drive_file_outlined)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.request});

  final ServiceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (request.status == ServiceRequestStatus.pending) {
      actions.add(
        HomeFixButton(
          label: 'عرض عروض الفنيين',
          icon: Icons.local_offer_outlined,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOffersScreen(requestId: request.id))),
        ),
      );
    }
    if (request.status == ServiceRequestStatus.accepted || request.status == ServiceRequestStatus.scheduled || request.status == ServiceRequestStatus.inProgress) {
      actions.add(
        HomeFixButton(
          label: 'تفاصيل الحجز والتحقق',
          icon: Icons.event_available_outlined,
          variant: HomeFixButtonVariant.secondary,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerBookingScreen(requestId: request.id))),
        ),
      );
    }
    if (request.status == ServiceRequestStatus.completed || request.status == ServiceRequestStatus.scheduled) {
      actions.add(
        HomeFixButton(
          label: 'فتح الدفع',
          icon: Icons.payments_outlined,
          variant: HomeFixButtonVariant.outline,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: request))),
        ),
      );
    }
    if (request.status == ServiceRequestStatus.completed && request.technicianId != null && request.technicianId!.isNotEmpty) {
      actions.add(
        HomeFixButton(
          label: 'تقييم الخدمة',
          icon: Icons.star_outline_rounded,
          variant: HomeFixButtonVariant.secondary,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ReviewDialog(
              requestId: request.id,
              technicianId: request.technicianId!,
              technicianName: request.technicianName ?? 'الفني',
              serviceNameAr: request.serviceNameAr,
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return HomeFixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('الخطوة التالية', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDesignTokens.space3),
          ...actions.map((action) => Padding(padding: const EdgeInsets.only(bottom: AppDesignTokens.space2), child: action)),
        ],
      ),
    );
  }
}
