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
  ServiceRequestModel? _request;
  bool _loading = true;
  String? _error;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_refreshing) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final state = context.read<AppStateProvider>();
      await state.refreshAuthenticatedData();
      final request = state.customerRequests.cast<ServiceRequestModel?>().firstWhere(
            (item) => item?.id == widget.requestId,
            orElse: () => null,
          );
      if (!mounted) return;
      setState(() {
        _request = request;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = stateMessage(e);
      });
    }
  }

  String stateMessage(Object error) => 'تعذر تحميل تفاصيل الطلب. يرجى المحاولة مرة أخرى.';

  @override
  Widget build(BuildContext context) {
    final request = _request;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('طلب #${widget.requestId}')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_refreshing) return;
          _refreshing = true;
          try {
            await _load();
          } finally {
            _refreshing = false;
          }
        },
        child: _loading
            ? const ListView(padding: EdgeInsets.all(AppDesignTokens.space4), children: [HomeFixSkeletonList(itemCount: 5)])
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(AppDesignTokens.space4),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.65,
                        child: HomeFixErrorState(
                          title: 'تعذر تحميل الطلب',
                          message: _error!,
                          onRetry: _load,
                        ),
                      ),
                    ],
                  )
                : request == null
                    ? ListView(
                        padding: const EdgeInsets.all(AppDesignTokens.space4),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.65,
                            child: const HomeFixEmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'الطلب غير موجود',
                              message: 'قد يكون الطلب غير متاح أو تم تحديث البيانات. حاول مرة أخرى.',
                            ),
                          ),
                        ],
                      )
                    : _buildContent(context, request),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceRequestModel request) {
    final padding = AppResponsive.pagePadding(context);
    final statusTone = _toneFor(request.status);
    final hasBooking = {
      ServiceRequestStatus.accepted,
      ServiceRequestStatus.scheduled,
      ServiceRequestStatus.inProgress,
      ServiceRequestStatus.completed,
    }.contains(request.status);

    return ListView(
      padding: padding.copyWith(bottom: AppDesignTokens.space8),
      children: [
        HomeFixCard(
          gradient: AppColors.primaryGradient,
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
                        Text('طلب الخدمة', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                        const SizedBox(height: AppDesignTokens.space1),
                        Text(request.serviceNameAr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  HomeFixStatusChip(label: request.status.displayNameAr, tone: statusTone, icon: Icons.circle),
                ],
              ),
              const SizedBox(height: AppDesignTokens.space4),
              Text('رقم الطلب: #${request.id}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.space4),
        HomeFixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeFixSectionHeader(title: 'حالة الطلب', subtitle: 'آخر حالة مؤكدة من الخادم'),
              const SizedBox(height: AppDesignTokens.space4),
              for (var i = 0; i < _timeline.length; i++)
                _TimelineItem(
                  label: _timeline[i].$1,
                  tone: _timeline[i].$2,
                  active: _statusStep(request.status) >= i,
                  showConnector: i < _timeline.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.space4),
        HomeFixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeFixSectionHeader(title: 'تفاصيل الخدمة'),
              const SizedBox(height: AppDesignTokens.space3),
              _DetailRow(icon: Icons.home_repair_service_outlined, label: 'الخدمة', value: request.serviceNameAr),
              const SizedBox(height: AppDesignTokens.space2),
              _DetailRow(icon: Icons.location_on_outlined, label: 'العنوان', value: request.address.fullAddressDescription),
              const SizedBox(height: AppDesignTokens.space2),
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'الموعد المفضل', value: '${request.preferredDate} · ${request.preferredTime}'),
              const SizedBox(height: AppDesignTokens.space2),
              _DetailRow(icon: Icons.notes_outlined, label: 'وصف المشكلة', value: request.problemDescription),
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.space4),
        HomeFixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeFixSectionHeader(title: 'التسعير'),
              const SizedBox(height: AppDesignTokens.space3),
              Text(
                request.finalPrice != null
                    ? '${request.finalPrice!.toStringAsFixed(2)} ج.م'
                    : request.estimatedPriceMin > 0
                        ? '${request.estimatedPriceMin.toStringAsFixed(2)} ج.م – ${request.estimatedPriceMax.toStringAsFixed(2)} ج.م'
                        : 'سيظهر السعر النهائي بعد اعتماد عرض الفني.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        if (request.files.isNotEmpty) ...[
          const SizedBox(height: AppDesignTokens.space4),
          HomeFixCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeFixSectionHeader(title: 'المرفقات'),
                const SizedBox(height: AppDesignTokens.space3),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: request.files.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDesignTokens.space2),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                      child: Image.network(
                        request.files[index].url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: AppColors.borderLight,
                          child: const Icon(Icons.insert_drive_file_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDesignTokens.space5),
        if (request.status == ServiceRequestStatus.pending)
          HomeFixButton(
            label: 'مشاهدة عروض الفنيين',
            icon: Icons.local_offer_outlined,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOffersScreen(requestId: request.id))),
          ),
        if (hasBooking) ...[
          if (request.status == ServiceRequestStatus.pending) const SizedBox(height: AppDesignTokens.space2),
          HomeFixButton(
            label: 'تفاصيل الحجز والتحقق',
            icon: Icons.event_available_outlined,
            variant: HomeFixButtonVariant.secondary,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerBookingScreen(requestId: request.id))),
          ),
        ],
        if (request.status != ServiceRequestStatus.cancelled && request.finalPrice != null) ...[
          const SizedBox(height: AppDesignTokens.space2),
          HomeFixButton(
            label: 'الدفع',
            icon: Icons.payments_outlined,
            variant: HomeFixButtonVariant.outline,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPaymentScreen(request: request))),
          ),
        ],
        if (request.status == ServiceRequestStatus.completed && request.technicianId != null) ...[
          const SizedBox(height: AppDesignTokens.space2),
          HomeFixButton(
            label: 'تقييم الخدمة',
            icon: Icons.star_rounded,
            variant: HomeFixButtonVariant.outline,
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
        ],
      ],
    );
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

  int _statusStep(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 0;
      case ServiceRequestStatus.accepted:
      case ServiceRequestStatus.scheduled:
        return 1;
      case ServiceRequestStatus.inProgress:
        return 2;
      case ServiceRequestStatus.completed:
        return 3;
      case ServiceRequestStatus.cancelled:
        return 0;
    }
  }

  List<(String, HomeFixStatusTone)> get _timeline => const [
        ('قيد المراجعة', HomeFixStatusTone.warning),
        ('تم قبول الطلب', HomeFixStatusTone.info),
        ('جاري تنفيذ الخدمة', HomeFixStatusTone.technician),
        ('اكتملت الخدمة', HomeFixStatusTone.success),
      ];
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.label, required this.tone, required this.active, required this.showConnector});

  final String label;
  final HomeFixStatusTone tone;
  final bool active;
  final bool showConnector;

  Color _color() {
    switch (tone) {
      case HomeFixStatusTone.success:
        return AppColors.success;
      case HomeFixStatusTone.warning:
        return AppColors.warning;
      case HomeFixStatusTone.error:
        return AppColors.error;
      case HomeFixStatusTone.technician:
        return AppColors.technicianPrimary;
      case HomeFixStatusTone.info:
        return AppColors.primary;
      case HomeFixStatusTone.neutral:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: active ? color : AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: SizedBox(width: 16, height: 16, child: active ? Icon(Icons.check_rounded, size: 11, color: Colors.white) : null),
              ),
              if (showConnector) Container(width: 2, height: 28, color: color.withValues(alpha: 0.35)),
            ],
          ),
        ),
        const SizedBox(width: AppDesignTokens.space3),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDesignTokens.space3),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppDesignTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: AppDesignTokens.space1),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
