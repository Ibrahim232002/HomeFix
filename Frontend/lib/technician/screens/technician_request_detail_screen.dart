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

class TechnicianRequestDetailScreen extends StatefulWidget {
  final ServiceRequestModel request;
  const TechnicianRequestDetailScreen({super.key, required this.request});

  @override
  State<TechnicianRequestDetailScreen> createState() => _TechnicianRequestDetailScreenState();
}

class _TechnicianRequestDetailScreenState extends State<TechnicianRequestDetailScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _createOffer() async {
    if (_submitting) return;
    final priceController = TextEditingController(
      text: widget.request.estimatedPriceMin > 0 ? widget.request.estimatedPriceMin.toStringAsFixed(0) : '',
    );
    final noteController = TextEditingController();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرسال عرض للعميل'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'السعر المقترح (ج.م)')),
          const SizedBox(height: AppDesignTokens.space3),
          TextField(controller: noteController, maxLines: 3, decoration: const InputDecoration(labelText: 'ملاحظة للعميل (اختياري)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, [priceController.text.trim(), noteController.text.trim()]), child: const Text('متابعة')),
        ],
      ),
    );
    priceController.dispose();
    noteController.dispose();
    if (result == null) return;
    final price = double.tryParse(result[0]);
    if (price == null || price <= 0) {
      setState(() => _error = 'أدخل سعراً صحيحاً أكبر من صفر.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      await context.read<AppStateProvider>().createOffer(widget.request, proposedPrice: price, technicianNote: result[1]);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() { _submitting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AppStateProvider>().refreshAuthenticatedData(),
          child: ListView(
            padding: AppResponsive.pagePadding(context),
            children: [
              AppResponsive.content(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                HomeFixCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(request.serviceNameAr, style: Theme.of(context).textTheme.headlineSmall)), HomeFixStatusChip(label: request.status.displayNameAr, tone: HomeFixStatusTone.technician)]),
                    const SizedBox(height: AppDesignTokens.space3),
                    Text(request.problemDescription, style: Theme.of(context).textTheme.bodyLarge),
                  ]),
                ),
                const SizedBox(height: AppDesignTokens.space3),
                HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('الموعد', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDesignTokens.space2),
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: Text(request.preferredDate), subtitle: Text(request.preferredTime)),
                ])),
                const SizedBox(height: AppDesignTokens.space3),
                HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('العنوان', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDesignTokens.space2),
                  Text(request.address.fullAddressDescription),
                ])),
                const SizedBox(height: AppDesignTokens.space3),
                HomeFixCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('نطاق السعر المرجعي', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDesignTokens.space2),
                  Text(request.estimatedPriceMin > 0 || request.estimatedPriceMax > 0 ? '${request.estimatedPriceMin.toStringAsFixed(0)} - ${request.estimatedPriceMax.toStringAsFixed(0)} ج.م' : 'غير محدد حالياً', style: Theme.of(context).textTheme.titleLarge),
                ])),
                if (_error != null) ...[
                  const SizedBox(height: AppDesignTokens.space3),
                  HomeFixErrorState(title: 'تعذر إرسال العرض', message: _error, onRetry: _createOffer),
                ],
                const SizedBox(height: AppDesignTokens.space4),
                if (request.status == ServiceRequestStatus.pending || request.status == ServiceRequestStatus.offersReceived)
                  HomeFixButton(expanded: true, loading: _submitting, label: 'إرسال عرض للعميل', icon: Icons.local_offer_outlined, onPressed: _createOffer),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
