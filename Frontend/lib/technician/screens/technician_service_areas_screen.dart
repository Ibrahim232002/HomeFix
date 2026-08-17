import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';
import '../../services/app_state_provider.dart';

class TechnicianServiceAreasScreen extends StatefulWidget {
  const TechnicianServiceAreasScreen({super.key});
  @override
  State<TechnicianServiceAreasScreen> createState() => _TechnicianServiceAreasScreenState();
}

class _TechnicianServiceAreasScreenState extends State<TechnicianServiceAreasScreen> {
  final ITechnicianRepository _repo = TechnicianRepository();
  List<TechnicianServiceAreaDto> _areas = const [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  int? get _techId => int.tryParse(context.read<AppStateProvider>().currentTechProfile?.id ?? context.read<AppStateProvider>().currentUser?.id ?? '');

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final id = _techId; if (id == null) return;
    setState(() { _loading = true; _error = null; });
    try { final data = await _repo.getServiceAreas(id); if (mounted) setState(() { _areas = data; _loading = false; }); }
    catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); }); }
  }

  Future<void> _add() async {
    final id = _techId; if (id == null || _busy) return;
    final controller = TextEditingController();
    final value = await showDialog<int>(context: context, builder: (context) => AlertDialog(title: const Text('إضافة مدينة للخدمة'), content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'معرّف المدينة')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())), child: const Text('إضافة'))]));
    controller.dispose();
    if (value == null || value <= 0) return;
    if (_areas.any((a) => a.cityId == value)) { setState(() => _error = 'هذه المدينة مضافة بالفعل.'); return; }
    setState(() { _busy = true; _error = null; });
    try { await _repo.addServiceArea(CreateTechnicianServiceAreaRequest(technicianId: id, cityId: value)); await _load(); }
    catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _delete(TechnicianServiceAreaDto area) async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('حذف منطقة الخدمة؟'), content: Text('سيتم إزالة المدينة رقم ${area.cityId} من مناطق خدمتك.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))]));
    if (confirmed != true) return;
    setState(() { _busy = true; _error = null; });
    try { await _repo.deleteServiceArea(area.technicianId, area.cityId); await _load(); }
    catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('مناطق الخدمة')), floatingActionButton: FloatingActionButton.extended(onPressed: _busy ? null : _add, icon: const Icon(Icons.add_location_alt_outlined), label: const Text('إضافة مدينة')), body: RefreshIndicator(onRefresh: _load, child: ListView(padding: AppResponsive.pagePadding(context), physics: const AlwaysScrollableScrollPhysics(), children: [AppResponsive.content(context, child: _loading ? const HomeFixLoadingList(itemCount: 3) : _error != null ? HomeFixErrorState(title: 'تعذر تحميل مناطق الخدمة', message: _error, onRetry: _load) : _areas.isEmpty ? const SizedBox(height: 420, child: HomeFixEmptyState(icon: Icons.location_city_outlined, title: 'لا توجد مناطق مسجلة', message: 'أضف المدن التي تستقبل فيها طلبات الخدمة.')) : Column(children: _areas.map((area) => Padding(padding: const EdgeInsets.only(bottom: AppDesignTokens.space3), child: HomeFixCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.location_city_outlined)), title: Text('مدينة #${area.cityId}', style: Theme.of(context).textTheme.titleMedium), subtitle: Text('فني #${area.technicianId}'), trailing: IconButton(onPressed: _busy ? null : () => _delete(area), icon: const Icon(Icons.delete_outline_rounded))))).toList()))])));
  }
}
