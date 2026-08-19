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
      if (mounted) {
        setState(() {
          _governorates = values.where((item) => item.isActive).toList();
          _loadingGovernorates = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingGovernorates = false);
    }
  }

  Future<void> _showAddAddressDialog(BuildContext context) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final titleController = TextEditingController();
    final streetController = TextEditingController();
    final buildingController = TextEditingController();
    final floorController = TextEditingController();
    final apartmentController = TextEditingController();

    GovernorateDto? selectedGovernorate;
    CityDto? selectedCity;
    List<CityDto> cities = [];
    bool loadingCities = false;
    String? locationError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> loadCities(int governorateId) async {
              setDialogState(() {
                loadingCities = true;
                selectedCity = null;
                locationError = null;
              });
              try {
                final result = await _locationRepo.getCitiesByGovernorate(governorateId);
                setDialogState(() {
                  cities = result.where((item) => item.isActive).toList();
                  loadingCities = false;
                });
              } catch (e) {
                setDialogState(() {
                  cities = [];
                  loadingCities = false;
                  locationError = 'تعذر تحميل المدن المرتبطة بالمحافظة';
                });
              }
            }

            return AlertDialog(
              title: const Text('إضافة عنوان جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'اسم العنوان (مثل: المنزل، العمل)'),
                    ),
                    const SizedBox(height: 8),
                    if (_loadingGovernorates)
                      const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator()))
                    else
                      DropdownButtonFormField<GovernorateDto>(
                        value: selectedGovernorate,
                        decoration: const InputDecoration(labelText: 'المحافظة'),
                        items: _governorates
                            .map((item) => DropdownMenuItem<GovernorateDto>(
                                  value: item,
                                  child: Text(item.name ?? 'محافظة #${item.id}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          selectedGovernorate = value;
                          cities = [];
                          selectedCity = null;
                          setDialogState(() {});
                          loadCities(value.id);
                        },
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CityDto>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        helperText: selectedGovernorate == null ? 'اختر المحافظة أولاً' : null,
                        errorText: locationError,
                      ),
                      items: cities
                          .map((item) => DropdownMenuItem<CityDto>(
                                value: item,
                                child: Text(item.name ?? 'مدينة #${item.id}'),
                              ))
                          .toList(),
                      onChanged: selectedGovernorate == null || loadingCities
                          ? null
                          : (value) => setDialogState(() => selectedCity = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: streetController,
                      decoration: const InputDecoration(labelText: 'اسم الشارع'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: buildingController,
                      decoration: const InputDecoration(labelText: 'رقم/تفاصيل المبنى'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: floorController,
                            decoration: const InputDecoration(labelText: 'الطابق'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: apartmentController,
                            decoration: const InputDecoration(labelText: 'الشقة'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (selectedGovernorate == null || selectedCity == null) {
                      setDialogState(() => locationError = 'يرجى اختيار المحافظة والمدينة');
                      return;
                    }
                    if (streetController.text.trim().isEmpty) {
                      setDialogState(() => locationError = 'يرجى إدخال اسم الشارع');
                      return;
                    }

                    final newAddr = AddressModel(
                      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                      userId: appState.currentUser?.id ?? '',
                      title: titleController.text.trim().isEmpty ? 'عنوان جديد' : titleController.text.trim(),
                      governorate: selectedGovernorate!.name ?? '',
                      city: selectedCity!.name ?? '',
                      street: streetController.text.trim(),
                      building: buildingController.text.trim(),
                      floor: floorController.text.trim(),
                      apartment: apartmentController.text.trim(),
                      isDefault: appState.savedAddresses.isEmpty,
                      governorateId: selectedGovernorate!.id,
                      cityId: selectedCity!.id,
                    );

                    try {
                      await appState.addAddress(newAddr);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت إضافة العنوان بنجاح')),
                      );
                    } catch (e) {
                      setDialogState(() => locationError = e.toString().replaceFirst('Exception: ', ''));
                    }
                  },
                  child: const Text('حفظ العنوان', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                ),
              ],
            );
          },
        ),
      ),
    );

    titleController.dispose();
    streetController.dispose();
    buildingController.dispose();
    floorController.dispose();
    apartmentController.dispose();
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
