import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_field.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/api_dtos.dart';
import '../../repositories/address_repository.dart';
import '../../repositories/city_repository.dart';

class CustomerAddressesScreen extends StatefulWidget {
  const CustomerAddressesScreen({super.key});

  @override
  State<CustomerAddressesScreen> createState() => _CustomerAddressesScreenState();
}

class _CustomerAddressesScreenState extends State<CustomerAddressesScreen> {
  final IAddressRepository _repository = AddressRepository();
  final ICityRepository _cityRepository = CityRepository();
  List<AddressDto> _addresses = const [];
  Future<List<CityDto>>? _citiesFuture;
  bool _loading = true;
  String? _error;

  int? get _customerId => int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customerId = _customerId;
    if (customerId == null) {
      if (mounted) setState(() { _loading = false; _error = 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final addresses = await _repository.getAddressesByCustomerId(customerId);
      if (!mounted) return;
      setState(() { _addresses = addresses; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _message(e); });
    }
  }

  Future<List<CityDto>> _loadCities() {
    final inFlight = _citiesFuture;
    if (inFlight != null) return inFlight;
    final future = _cityRepository.getActiveCities();
    _citiesFuture = future.whenComplete(() => _citiesFuture = null);
    return future;
  }

  String _message(Object error) => error is ApiException ? error.message : 'تعذر تحميل البيانات. يرجى المحاولة مرة أخرى.';

  Future<void> _openEditor({AddressDto? address}) async {
    final customerId = _customerId;
    if (customerId == null) return;

    final label = TextEditingController(text: address?.label ?? '');
    final fullAddress = TextEditingController(text: address?.fullAddress ?? '');
    final building = TextEditingController(text: address?.buildingNumber ?? '');
    final floor = TextEditingController(text: address?.floorNumber ?? '');
    final apartment = TextEditingController(text: address?.apartmentNumber ?? '');
    final instructions = TextEditingController(text: address?.additionalInstructions ?? '');
    var selectedCityId = address?.cityId;
    var selectedGovernorateId = address?.governorateId;
    var isDefault = address?.isDefault ?? _addresses.isEmpty;
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? 'إضافة عنوان' : 'تعديل العنوان'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<CityDto>>(
                  future: _loadCities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Row(
                        children: [
                          const Expanded(child: Text('تعذر تحميل المدن. حاول مرة أخرى.')),
                          IconButton(onPressed: () => setDialogState(() {}), icon: const Icon(Icons.refresh_rounded)),
                        ],
                      );
                    }
                    final cities = snapshot.data ?? const <CityDto>[];
                    return DropdownButtonFormField<int>(
                      value: cities.any((city) => city.id == selectedCityId) ? selectedCityId : null,
                      decoration: const InputDecoration(labelText: 'المدينة', prefixIcon: Icon(Icons.location_city_outlined)),
                      items: cities
                          .map((city) => DropdownMenuItem<int>(value: city.id, child: Text(city.name ?? 'مدينة ${city.id}')))
                          .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              final city = cities.where((item) => item.id == value).firstOrNull;
                              setDialogState(() {
                                selectedCityId = value;
                                selectedGovernorateId = city?.governorateId;
                              });
                            },
                    );
                  },
                ),
                const SizedBox(height: 10),
                HomeFixField(controller: label, label: 'اسم العنوان', hintText: 'المنزل، العمل...'),
                const SizedBox(height: 10),
                HomeFixField(controller: fullAddress, label: 'العنوان الكامل', maxLines: 2),
                const SizedBox(height: 10),
                HomeFixField(controller: building, label: 'رقم المبنى'),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: HomeFixField(controller: floor, label: 'الدور')), const SizedBox(width: 10), Expanded(child: HomeFixField(controller: apartment, label: 'الشقة'))]),
                const SizedBox(height: 10),
                HomeFixField(controller: instructions, label: 'تعليمات إضافية', maxLines: 2),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: isDefault,
                  onChanged: saving ? null : (value) => setDialogState(() => isDefault = value),
                  title: const Text('جعله العنوان الافتراضي'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            HomeFixButton(
              expanded: false,
              loading: saving,
              label: address == null ? 'إضافة' : 'حفظ التعديل',
              icon: Icons.check_rounded,
              onPressed: saving ? null : () async {
                if (fullAddress.text.trim().isEmpty) return;
                if (selectedCityId == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('اختر المدينة أولاً لضبط التسعير حسب موقعك.')));
                  return;
                }
                setDialogState(() => saving = true);
                try {
                  if (address == null) {
                    final created = await _repository.createAddress(CreateAddressRequest(
                      customerId: customerId,
                      label: label.text.trim().isEmpty ? 'عنوان محفوظ' : label.text.trim(),
                      fullAddress: fullAddress.text.trim(),
                      buildingNumber: building.text.trim(),
                      floorNumber: floor.text.trim(),
                      apartmentNumber: apartment.text.trim(),
                      additionalInstructions: instructions.text.trim(),
                      isDefault: isDefault,
                      governorateId: selectedGovernorateId,
                      cityId: selectedCityId,
                    ));
                    if (mounted) setState(() => _addresses = [created, ..._addresses]);
                  } else {
                    final updated = await _repository.updateAddress(address.id, UpdateAddressRequest(
                      label: label.text.trim().isEmpty ? 'عنوان محفوظ' : label.text.trim(),
                      fullAddress: fullAddress.text.trim(),
                      buildingNumber: building.text.trim(),
                      floorNumber: floor.text.trim(),
                      apartmentNumber: apartment.text.trim(),
                      additionalInstructions: instructions.text.trim(),
                      isDefault: isDefault,
                      governorateId: selectedGovernorateId,
                      cityId: selectedCityId,
                    ));
                    if (mounted) setState(() => _addresses = _addresses.map((item) => item.id == updated.id ? updated : item).toList());
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ العنوان.')));
                } catch (e) {
                  if (dialogContext.mounted) {
                    setDialogState(() => saving = false);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(_message(e))));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
    label.dispose(); fullAddress.dispose(); building.dispose(); floor.dispose(); apartment.dispose(); instructions.dispose();
  }

  Future<void> _delete(AddressDto address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العنوان؟'),
        content: Text('سيتم حذف «${address.label ?? 'العنوان'}» من حسابك.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deleteAddress(address.id);
      if (!mounted) return;
      setState(() => _addresses = _addresses.where((item) => item.id != address.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف العنوان.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عناويني')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppResponsive.pagePadding(context),
            children: [
              AppResponsive.content(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading)
                      const HomeFixLoadingList(itemCount: 4)
                    else if (_error != null)
                      HomeFixErrorState(title: 'تعذر تحميل العناوين', message: _error, onRetry: _load)
                    else if (_addresses.isEmpty)
                      const SizedBox(height: 360, child: HomeFixEmptyState(icon: Icons.location_off_outlined, title: 'لا توجد عناوين محفوظة', message: 'أضف عنواناً واضحاً لتسهيل وصول الفني إلى مكان الخدمة.'))
                    else ..._addresses.map((address) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeFixCard(
                        borderColor: address.isDefault ? AppColors.primary : AppColors.border,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const DecoratedBox(decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle), child: Padding(padding: EdgeInsets.all(10), child: Icon(Icons.location_on_rounded, color: AppColors.primary))),
                                const SizedBox(width: 12),
                                Expanded(child: Text(address.label?.isNotEmpty == true ? address.label! : 'عنوان محفوظ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                                if (address.isDefault) const Chip(avatar: Icon(Icons.check_rounded, size: 16), label: Text('افتراضي')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(address.fullAddress?.isNotEmpty == true ? address.fullAddress! : 'لا توجد تفاصيل للعنوان.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            if ([address.buildingNumber, address.floorNumber, address.apartmentNumber].any((value) => value?.isNotEmpty == true)) ...[
                              const SizedBox(height: 8),
                              Text('مبنى ${address.buildingNumber ?? '-'} • دور ${address.floorNumber ?? '-'} • شقة ${address.apartmentNumber ?? '-'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                            if (address.cityId == null) ...[
                              const SizedBox(height: 8),
                              Text('المدينة غير محددة — عدّل العنوان لإكمال التسعير حسب الموقع.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                            ],
                            const SizedBox(height: 12),
                            Row(children: [Expanded(child: HomeFixButton(expanded: true, variant: HomeFixButtonVariant.outline, icon: Icons.edit_outlined, label: 'تعديل', onPressed: () => _openEditor(address: address))), const SizedBox(width: 8), IconButton(tooltip: 'حذف', onPressed: () => _delete(address), icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error))]),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: HomeFixButton(expanded: false, icon: Icons.add_location_alt_outlined, label: 'إضافة عنوان', onPressed: () => _openEditor()),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
