import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_request_offer_model.dart';
import '../../services/app_state_provider.dart';

class CustomerOffersScreen extends StatefulWidget {
  const CustomerOffersScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<CustomerOffersScreen> createState() => _CustomerOffersScreenState();
}

class _CustomerOffersScreenState extends State<CustomerOffersScreen> {
  late Future<List<ServiceRequestOfferModel>> _future;
  final Set<String> _busyOffers = <String>{};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ServiceRequestOfferModel>> _load() => context.read<AppStateProvider>().loadOffersForRequest(widget.requestId);

  Future<void> _refresh() async {
    if (_busyOffers.contains('__refresh__')) return;
    setState(() => _busyOffers.add('__refresh__'));
    try {
      await _future;
      if (mounted) setState(() => _future = _load());
    } finally {
      if (mounted) setState(() => _busyOffers.remove('__refresh__'));
    }
  }

  String _safeError(Object error) => error is ApiException ? error.message : 'حدث خطأ أثناء تحميل العروض. حاول مرة أخرى.';

  HomeFixStatusTone _tone(String status) => switch (status.toLowerCase()) {
        'accepted' => HomeFixStatusTone.success,
        'rejected' => HomeFixStatusTone.error,
        'expired' => HomeFixStatusTone.warning,
        _ => HomeFixStatusTone.info,
      };

  Future<void> _accept(ServiceRequestOfferModel offer) async {
    if (_busyOffers.contains(offer.id)) return;
    final confirmed = await _confirm(
      title: 'تأكيد قبول العرض',
      message: 'سيتم قبول عرض ${offer.technicianName.isEmpty ? 'الفني' : offer.technicianName} بالسعر ${offer.proposedPrice.toStringAsFixed(2)} ج.م وإنشاء الحجز من خلال الخادم.',
      confirmLabel: 'قبول العرض',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyOffers.add(offer.id));
    try {
      await context.read<AppStateProvider>().acceptOffer(offer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول العرض بنجاح.')));
      setState(() => _future = _load());
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'تعذر قبول العرض. حاول مرة أخرى.')));
    } finally {
      if (mounted) setState(() => _busyOffers.remove(offer.id));
    }
  }

  Future<void> _reject(ServiceRequestOfferModel offer) async {
    if (_busyOffers.contains(offer.id)) return;
    final confirmed = await _confirm(
      title: 'رفض هذا العرض؟',
      message: 'سيتم إرسال قرار الرفض إلى الخادم، ويمكنك مراجعة بقية العروض المتاحة.',
      confirmLabel: 'رفض العرض',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyOffers.add(offer.id));
    try {
      await context.read<AppStateProvider>().rejectOffer(offer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض العرض.')));
      setState(() => _future = _load());
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'تعذر رفض العرض. حاول مرة أخرى.')));
    } finally {
      if (mounted) setState(() => _busyOffers.remove(offer.id));
    }
  }

  Future<bool> _confirm({required String title, required String message, required String confirmLabel, required bool destructive}) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
              FilledButton(
                style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white) : null,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('عروض الطلب #${widget.requestId}'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _busyOffers.contains('__refresh__') ? null : _refresh,
            icon: _busyOffers.contains('__refresh__')
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<ServiceRequestOfferModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              padding: AppResponsive.pagePadding(context),
              children: const [HomeFixSkeletonList(itemCount: 4)],
            );
          }

          if (snapshot.hasError) {
            return HomeFixErrorState(
              title: 'تعذر تحميل العروض',
              message: _safeError(snapshot.error!),
              onRetry: () => setState(() => _future = _load()),
            );
          }

          final offers = snapshot.data ?? const <ServiceRequestOfferModel>[];
          if (offers.isEmpty) {
            return const HomeFixEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'لا توجد عروض بعد',
              message: 'سيظهر هنا كل عرض حقيقي يقدمه الفنّيون على هذا الطلب.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppResponsive.pagePadding(context).add(const EdgeInsets.only(bottom: AppDesignTokens.space8)),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDesignTokens.space3),
              itemBuilder: (context, index) => _OfferCard(
                offer: offers[index],
                busy: _busyOffers.contains(offers[index].id),
                onAccept: () => _accept(offers[index]),
                onReject: () => _reject(offers[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  HomeFixStatusTone toneFor(String status) => _tone(status);
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.busy, required this.onAccept, required this.onReject});

  final ServiceRequestOfferModel offer;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final pending = offer.status.toLowerCase() == 'pending';
    final statusTone = switch (offer.status.toLowerCase()) {
      'accepted' => HomeFixStatusTone.success,
      'rejected' => HomeFixStatusTone.error,
      'expired' => HomeFixStatusTone.warning,
      _ => HomeFixStatusTone.info,
    };

    return HomeFixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person_outline_rounded)),
              const SizedBox(width: AppDesignTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.technicianName.isEmpty ? 'فني الخدمة' : offer.technicianName, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text('عرض مقدم على الطلب #${offer.serviceRequestId}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              HomeFixStatusChip(label: offer.status, tone: statusTone, icon: Icons.circle),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDesignTokens.space4),
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر المقترح من الفني', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppDesignTokens.space1),
                Text('${offer.proposedPrice.toStringAsFixed(2)} ج.م', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryDark)),
              ],
            ),
          ),
          if (offer.technicianNote.trim().isNotEmpty) ...[
            const SizedBox(height: AppDesignTokens.space4),
            Text('ملاحظات الفني', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppDesignTokens.space1),
            Text(offer.technicianNote, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: AppDesignTokens.space4),
          Text('قُدّم في ${offer.createdAt}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          if (pending) ...[
            const SizedBox(height: AppDesignTokens.space4),
            Row(
              children: [
                Expanded(child: HomeFixButton(label: 'قبول العرض', icon: Icons.check_rounded, loading: busy, onPressed: onAccept)),
                const SizedBox(width: AppDesignTokens.space2),
                Expanded(child: HomeFixButton(label: 'رفض', icon: Icons.close_rounded, variant: HomeFixButtonVariant.outline, loading: false, onPressed: busy ? null : onReject)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
