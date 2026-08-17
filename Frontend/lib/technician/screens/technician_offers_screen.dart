import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_request_offer_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianOffersScreen extends StatefulWidget {
  const TechnicianOffersScreen({super.key});

  @override
  State<TechnicianOffersScreen> createState() => _TechnicianOffersScreenState();
}

class _TechnicianOffersScreenState extends State<TechnicianOffersScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AppStateProvider>().refreshAuthenticatedData();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  HomeFixStatusTone _tone(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return HomeFixStatusTone.success;
      case 'rejected':
      case 'cancelled': return HomeFixStatusTone.error;
      case 'expired': return HomeFixStatusTone.warning;
      default: return HomeFixStatusTone.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = context.watch<AppStateProvider>().offers;
    return Scaffold(
      appBar: AppBar(title: const Text('عروضي')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppResponsive.pagePadding(context),
          children: [
            AppResponsive.content(context, child: _loading
                ? const HomeFixLoadingList(itemCount: 4)
                : _error != null
                    ? HomeFixErrorState(title: 'تعذر تحميل العروض', message: _error, onRetry: _load)
                    : offers.isEmpty
                        ? const SizedBox(height: 420, child: HomeFixEmptyState(icon: Icons.local_offer_outlined, title: 'لا توجد عروض', message: 'ستظهر العروض التي أرسلتها للعملاء هنا.'))
                        : Column(
                            children: offers.map((ServiceRequestOfferModel offer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppDesignTokens.space3),
                                child: HomeFixCard(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [Expanded(child: Text('طلب #${offer.serviceRequestId}', style: Theme.of(context).textTheme.titleMedium)), HomeFixStatusChip(label: offer.status, tone: _tone(offer.status))]),
                                    const SizedBox(height: AppDesignTokens.space3),
                                    Text('${offer.proposedPrice.toStringAsFixed(2)} ج.م', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.technicianDark)),
                                    if (offer.technicianNote.isNotEmpty) ...[
                                      const SizedBox(height: AppDesignTokens.space2),
                                      Text(offer.technicianNote, style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                    const SizedBox(height: AppDesignTokens.space2),
                                    Text('أُرسل: ${offer.createdAt}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                                  ]),
                                ),
                              );
                            }).toList(),
                          )),
          ],
        ),
      ),
    );
  }
}
