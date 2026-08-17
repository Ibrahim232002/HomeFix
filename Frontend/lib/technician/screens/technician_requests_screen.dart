import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianRequestsScreen extends StatelessWidget {
  const TechnicianRequestsScreen({super.key});

  Future<void> _createOffer(BuildContext context, ServiceRequestModel request) async {
    final appState = context.read<AppStateProvider>();
    final priceController = TextEditingController(
      text: request.estimatedPriceMin > 0 ? request.estimatedPriceMin.toStringAsFixed(0) : '',
    );
    final noteController = TextEditingController();
    var submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final price = double.tryParse(priceController.text.trim());
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل سعراً صحيحاً.')));
                return;
              }
              if (submitting) return;
              setDialogState(() => submitting = true);
              try {
                await appState.createOffer(
                  request,
                  proposedPrice: price,
                  technicianNote: noteController.text,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال العرض للعميل بنجاح.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (dialogContext.mounted) setDialogState(() => submitting = false);
              }
            }

            return AlertDialog(
              title: const Text('إرسال عرض للعميل'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'السعر المقترح (ج.م)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'ملاحظة للعميل (اختياري)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : submit,
                  child: submitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('إرسال العرض'),
                ),
              ],
            );
          },
        );
      },
    );

    priceController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppStateProvider>().availableTechRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('طلبات الصيانة المتاحة')),
      body: requests.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'لا توجد طلبات متاحة حالياً',
              description: 'ستظهر هنا الطلبات التي يمكنك تقديم عروض عليها.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(request.serviceNameAr, style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('#${request.id}', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(request.problemDescription),
                        const SizedBox(height: 10),
                        Text('الموعد: ${request.preferredDate} (${request.preferredTime})'),
                        const SizedBox(height: 6),
                        Text(
                          'السعر المرجعي: ${request.estimatedPriceMin.toStringAsFixed(0)} - ${request.estimatedPriceMax.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _createOffer(context, request),
                          icon: const Icon(Icons.local_offer_outlined),
                          label: const Text('إرسال عرض'),
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
