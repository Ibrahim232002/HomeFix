import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/address_model.dart';
import '../../models/api_dtos.dart';
import '../../repositories/governorate_city_repository.dart';
import '../../services/app_state_provider.dart';

class CustomerAddressesScreen extends StatefulWidget {
  const CustomerAddressesScreen({Key? key}) : super(key: key);

  @override
  State<CustomerAddressesScreen> createState() => _CustomerAddressesScreenState();
}

class _CustomerAddressesScreenState extends State<CustomerAddressesScreen> {
  final IGovernorateCityRepository _locationRepo = GovernorateCityRepository();
  List<GovernorateDto> _governorates = [];
  bool _loadingGovernorates = true;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    try {
      final values = await _locationRepo.getGovernorates();
      if (!mounted) return;
      setState(() {
        _governorates = values.where((item) => item.isActive).toList();
        _loadingGovernorates = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingGovernorates = false);
    }
  }

  Future<void> _showAddAddressDialog(BuildContext context) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => _AddressEditorDialog(
        locationRepo: _locationRepo,
        governorates: _governorates,
        appState: appState,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('عناويني المسجلة')),
      body: appState.savedAddresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('لا توجد عناوين مسجلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo', color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('أضف عنوانك لتسهيل وصول الفني إليك بدقة', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo'), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: appState.savedAddresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = appState.savedAddresses[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: addr.isDefault ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: addr.isDefault ? AppColors.primarySurface : AppColors.scaffoldBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: addr.isDefault ? AppColors.primary : AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(addr.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('الرئيسي', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(addr.fullAddressDescription, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddAddressDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة عنوان جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class _AddressEditorDialog extends StatefulWidget {
  final IGovernorateCityRepository locationRepo;
  final List<GovernorateDto> governorates;
  final AppStateProvider appState;

  const _AddressEditorDialog({
    required this.locationRepo,
    required this.governorates,
    required this.appState,
  });

  @override
  State<_AddressEditorDialog> createState() => _AddressEditorDialogState();
}

class _AddressEditorDialogState extends State<_AddressEditorDialog> {
  final _labelController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _instructionsController = TextEditingController();

  GovernorateDto? _selectedGovernorate;
  CityDto? _selectedCity;
  List<CityDto> _cities = [];
  bool _loadingCities = false;
  bool _saving = false;
  String? _locationError;

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadCities(int governorateId) async {
    if (!mounted) return;
    setState(() {
      _loadingCities = true;
      _selectedCity = null;
      _cities = [];
      _locationError = null;
    });

    try {
      final result = await widget.locationRepo.getCitiesByGovernorate(governorateId);
      if (!mounted) return;
      setState(() {
        _cities = result.where((item) => item.isActive).toList();
        _loadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cities = [];
        _loadingCities = false;
        _locationError = 'تعذر تحميل المدن المرتبطة بالمحافظة';
      });
    }
  }

  Future<void> _save() async {
    if (_selectedGovernorate == null || _selectedCity == null) {
      setState(() => _locationError = 'يرجى اختيار المحافظة والمدينة');
      return;
    }
    if (_fullAddressController.text.trim().isEmpty) {
      setState(() => _locationError = 'يرجى إدخال العنوان بالتفصيل');
      return;
    }

    setState(() => _saving = true);

    final newAddr = AddressModel(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.appState.currentUser?.id ?? '',
      title: _labelController.text.trim().isEmpty ? 'عنوان جديد' : _labelController.text.trim(),
      governorate: _selectedGovernorate!.name ?? '',
      city: _selectedCity!.name ?? '',
      street: _fullAddressController.text.trim(),
      building: _buildingController.text.trim(),
      floor: _floorController.text.trim(),
      apartment: _apartmentController.text.trim(),
      isDefault: widget.appState.savedAddresses.isEmpty,
      governorateId: _selectedGovernorate!.id,
      cityId: _selectedCity!.id,
    );

    try {
      await widget.appState.addAddress(newAddr);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة العنوان بنجاح')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _locationError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة عنوان جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'اسم العنوان (مثل: المنزل، العمل)'),
                enabled: !_saving,
              ),
              const SizedBox(height: 8),
              if (widget.governorates.isEmpty)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('لا توجد محافظات متاحة حالياً', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                )
              else
                DropdownButtonFormField<GovernorateDto>(
                  value: _selectedGovernorate,
                  decoration: const InputDecoration(labelText: 'المحافظة'),
                  items: widget.governorates
                      .map((item) => DropdownMenuItem<GovernorateDto>(
                            value: item,
                            child: Text(item.name ?? 'محافظة #${item.id}'),
                          ))
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _selectedGovernorate = value);
                          _loadCities(value.id);
                        },
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CityDto>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  helperText: _selectedGovernorate == null ? 'اختر المحافظة أولاً' : null,
                  errorText: _locationError,
                ),
                items: _cities
                    .map((item) => DropdownMenuItem<CityDto>(
                          value: item,
                          child: Text(item.name ?? 'مدينة #${item.id}'),
                        ))
                    .toList(),
                onChanged: _saving || _selectedGovernorate == null || _loadingCities
                    ? null
                    : (value) => setState(() => _selectedCity = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fullAddressController,
                decoration: const InputDecoration(labelText: 'العنوان بالتفصيل'),
                maxLines: 2,
                enabled: !_saving,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _buildingController,
                decoration: const InputDecoration(labelText: 'رقم/تفاصيل المبنى'),
                enabled: !_saving,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _floorController,
                      decoration: const InputDecoration(labelText: 'الطابق'),
                      keyboardType: TextInputType.number,
                      enabled: !_saving,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _apartmentController,
                      decoration: const InputDecoration(labelText: 'الشقة'),
                      keyboardType: TextInputType.number,
                      enabled: !_saving,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'تعليمات إضافية'),
                maxLines: 2,
                enabled: !_saving,
              ),
              if (_loadingCities) ...[
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('حفظ العنوان', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
