import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianSpecializationCard extends StatefulWidget {
  const TechnicianSpecializationCard({super.key});

  @override
  State<TechnicianSpecializationCard> createState() => _TechnicianSpecializationCardState();
}

class _TechnicianSpecializationCardState extends State<TechnicianSpecializationCard> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  int? _categoryId;
  String _categoryName = '';
  Set<int> _selectedServiceIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final appState = context.read<AppStateProvider>();
    final profile = appState.currentTechProfile;
    final technicianId = int.tryParse(profile?.id ?? '');
    if (technicianId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحديد ملف الفني.';
      });
      return;
    }

    final categories = appState.categories;
    final allServices = appState.services;
    final categoryId = profile?.categoryId;
    final serviceIds = profile?.serviceIds.toSet() ?? <int>{};
    String categoryName = profile?.categoryName ?? '';
    if (categoryId != null) {
      final category = categories.where((item) => int.tryParse(item.id) == categoryId).firstOrNull;
      categoryName = category?.nameAr ?? categoryName;
    }

    final services = categoryId == null
        ? <ServiceModel>[]
        : allServices.where((service) => int.tryParse(service.categoryId) == categoryId).toList();

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _categoryId = categoryId;
      _categoryName = categoryName;
      _services = services;
      _selectedServiceIds = serviceIds.intersection(
        services.map((s) => int.tryParse(s.id)).whereType<int>().toSet(),
      );
      _loading = false;
      _error = null;
    });
  }

  Future<void> _selectCategory() async {
    if (_categories.isEmpty) return;

    final selected = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('اختر التخصص', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final category = _categories[index];
                      final isSelected = int.tryParse(category.id) == _categoryId;
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          tileColor: isSelected ? AppColors.technicianLight : Colors.white,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.technicianLight,
                            child: Icon(Icons.build_rounded, color: AppColors.technicianPrimary),
                          ),
                          title: Text(category.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.technicianPrimary) : null,
                          onTap: () => Navigator.pop(context, category),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (selected == null) return;
    final newCategoryId = int.tryParse(selected.id);
    if (newCategoryId == null) return;

    setState(() {
      _categoryId = newCategoryId;
      _categoryName = selected.nameAr;
      _selectedServiceIds.clear();
      _services = [];
      _loading = true;
      _error = null;
    });

    try {
      final allServices = context.read<AppStateProvider>().services;
      final services = allServices
          .where((service) => int.tryParse(service.categoryId) == newCategoryId)
          .toList();
      if (!mounted) return;
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errorMessageFrom(e);
      });
    }
  }

  void _toggleService(String serviceId) {
    final id = int.tryParse(serviceId);
    if (id == null) return;
    setState(() {
      if (_selectedServiceIds.contains(id)) {
        _selectedServiceIds.remove(id);
      } else {
        _selectedServiceIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    final appState = context.read<AppStateProvider>();
    final technicianId = int.tryParse(appState.currentTechProfile?.id ?? '');
    if (technicianId == null || _categoryId == null) {
      if (!mounted) return;
      setState(() => _error = 'اختر تخصصًا أولًا.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await appState.updateTechnicianSpecialization(
        categoryId: _categoryId!,
        serviceIds: _selectedServiceIds.toList()..sort(),
      );

      if (!mounted) return;
      final updatedProfile = context.read<AppStateProvider>().currentTechProfile;
      setState(() {
        _saving = false;
        _categoryId = updatedProfile?.categoryId ?? _categoryId;
        _categoryName = updatedProfile?.categoryName ?? _categoryName;
        _selectedServiceIds = updatedProfile?.serviceIds.toSet() ?? _selectedServiceIds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التخصص والخدمات بنجاح.', style: TextStyle(fontFamily: 'Cairo'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _errorMessageFrom(e);
      });
    }
  }

  String _errorMessageFrom(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'تعذر حفظ التخصص والخدمات.' : message;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _loading && _categories.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('التخصص', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _selectCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category_outlined, color: AppColors.technicianPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _categoryName.isEmpty ? 'اختر التخصص' : _categoryName,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                color: _categoryName.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('الخدمات التي أقدمها', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                  else if (_categoryId == null)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('اختر تخصصًا لعرض الخدمات المتاحة.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
                  else if (_services.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('لا توجد خدمات متاحة لهذا التخصص حاليًا.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
                  else
                    ..._services.map((service) {
                      final selected = _selectedServiceIds.contains(int.tryParse(service.id));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: selected ? AppColors.technicianLight : Colors.white,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: selected ? AppColors.technicianPrimary : AppColors.border,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: selected,
                            onChanged: (_) => _toggleService(service.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: Text(service.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                          ),
                        ),
                      );
                    }),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontFamily: 'Cairo', fontSize: 12)),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving || _categoryId == null ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.technicianPrimary,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('حفظ التخصص والخدمات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}