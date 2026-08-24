import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/inspection_model.dart';
import '../../services/app_state_provider.dart';
import 'customer_inspection_quote_screen.dart';

class CustomerInspectionsScreen extends StatefulWidget {
  const CustomerInspectionsScreen({super.key});

  @override
  State<CustomerInspectionsScreen> createState() => _CustomerInspectionsScreenState();
}

class _CustomerInspectionsScreenState extends State<CustomerInspectionsScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.loadCustomerInspections(provider.customerRequests.map((request) => request.id));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final inspections = provider.customerInspections;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('المعاينات والتسعير')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.errorDark)), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')))])))
                : inspections.isEmpty
                    ? const EmptyStateWidget(icon: Icons.fact_check_outlined, title: 'لا توجد معاينات', description: 'عند استخدام خدمة تعتمد على المعاينة ستظهر حالتها وعروض السعر هنا.')
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: inspections.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final InspectionModel inspection = inspections[index];
                            final matchingRequests = provider.customerRequests.where((r) => r.id == inspection.serviceRequestId);
                            final request = matchingRequests.isEmpty ? null : matchingRequests.first;
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(inspection.isCompleted ? Icons.check_rounded : Icons.fact_check_outlined)),
                                title: Text(request?.serviceNameAr ?? 'طلب #${inspection.serviceRequestId}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
                                subtitle: Text('المعاينة #${inspection.id} • ${inspection.status}\n${inspection.scheduledAt}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_left_rounded),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerInspectionQuoteScreen(requestId: inspection.serviceRequestId))),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
