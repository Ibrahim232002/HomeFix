import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../models/technician_service_area_model.dart';
import '../../services/app_state_provider.dart';
import 'technician_location_picker.dart';

class TechnicianServiceAreaCard extends StatefulWidget {
  const TechnicianServiceAreaCard({super.key});

  @override
  State<TechnicianServiceAreaCard> createState() => _TechnicianServiceAreaCardState();
}

class _TechnicianServiceAreaCardState extends State<TechnicianServiceAreaCard> {
  List<GovernorateDto> _governorates = const [];
  bool _loading = true;
  bool _refreshingAreas = false;
  String? _errorMessage;
  int? _removingCityId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    try {
      final governorates = await appState.loadGovernoratesForTechnician();
      if (!mounted) return;

      setState(() {
        _governorates = governorates;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _removeArea(int cityId) async {
    if (_removingCityId != null) return;

    setState(() {
      _removingCityId = cityId;
      _errorMessage = null;
    });

    debugPrint('[TECH_SERVICE_AREAS] removing city: $cityId');

    try {
      await Provider.of<AppStateProvider>(context, listen: false)
          .removeTechnicianServiceArea(cityId);
      if (!mounted) return;
      setState(() => _removingCityId = null);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _removingCityId = null;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _showAddAreaSheet() async {
    if (_governorates.isEmpty || _refreshingAreas) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    setState(() {
      _refreshingAreas = true;
      _errorMessage = null;
    });

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _AddServiceAreaSheet(
          governorates: _governorates,
          existingCityIds: appState.serviceAreas.map((area) => area.cityId).toSet(),
          loadCities: appState.loadCitiesForTechnician,
          addArea: appState.addTechnicianServiceArea,
        ),
      );

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _refreshingAreas = false);
    }
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final areas = appState.serviceAreas;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مناطق الخدمة',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 4),
          const Text(
            'أضف المدن التي يمكنك تقديم خدماتك فيها.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (areas.isEmpty)
              const Text(
                'لم تتم إضافة مناطق خدمة بعد',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
              )
            else
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: areas
                    .map((area) => _ServiceAreaChip(
                          area: area,
                          getCityName: appState.getCityName,
                          removing: _removingCityId == area.cityId,
                          onRemove: () => _removeArea(area.cityId),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _refreshingAreas ? null : _showAddAreaSheet,
                icon: _refreshingAreas
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_rounded, size: 19),
                label: const Text(
                  'إضافة منطقة خدمة',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              _ServiceAreaMessage(message: _errorMessage!),
            ],
          ],
        ],
      ),
    );
  }
}

class _ServiceAreaChip extends StatelessWidget {
  final TechnicianServiceAreaModel area;
  final Future<String?> Function(int cityId) getCityName;
  final bool removing;
  final VoidCallback onRemove;

  const _ServiceAreaChip({
    required this.area,
    required this.getCityName,
    required this.removing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        future: getCityName(area.cityId),
        builder: (context, snapshot) => Container(
          padding: const EdgeInsetsDirectional.only(start: 11, end: 5, top: 5, bottom: 5),
          decoration: BoxDecoration(
            color: AppColors.technicianLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.technicianPrimary.withOpacity(.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                snapshot.data ?? 'جاري التحميل...',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
              const SizedBox(width: 3),
              SizedBox(
                width: 26,
                height: 26,
                child: removing
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'إزالة منطقة الخدمة',
                        onPressed: onRemove,
                        icon: const Icon(Icons.close_rounded, size: 16),
                      ),
              ),
            ],
          ),
        ),
      );
}

class _AddServiceAreaSheet extends StatefulWidget {
  final List<GovernorateDto> governorates;
  final Set<int> existingCityIds;
  final Future<List<CityDto>> Function(int governorateId) loadCities;
  final Future<void> Function(int cityId) addArea;

  const _AddServiceAreaSheet({
    required this.governorates,
    required this.existingCityIds,
    required this.loadCities,
    required this.addArea,
  });

  @override
  State<_AddServiceAreaSheet> createState() => _AddServiceAreaSheetState();
}

class _AddServiceAreaSheetState extends State<_AddServiceAreaSheet> {
  int? _selectedGovernorateId;
  int? _selectedCityId;
  List<CityDto> _cities = const [];
  bool _loadingCities = false;
  bool _adding = false;
  String? _errorMessage;
  int _citiesRequestVersion = 0;

  Future<void> _selectGovernorate() async {
    final selectedId = await showTechnicianLocationPicker(
      context: context,
      title: 'اختر المحافظة',
      selectedId: _selectedGovernorateId,
      options: widget.governorates
          .map((governorate) => TechnicianLocationOption(
                id: governorate.id,
                label: governorate.name ?? 'محافظة',
              ))
          .toList(),
    );
    if (!mounted || selectedId == null || _adding) return;

    debugPrint('[TECH_SERVICE_AREAS] governorate selected: $selectedId');
    setState(() {
      _selectedGovernorateId = selectedId;
      _selectedCityId = null;
      _cities = const [];
      _loadingCities = true;
      _errorMessage = null;
    });

    await _loadCities(selectedId);
  }

  Future<void> _loadCities(int governorateId) async {
    final requestVersion = ++_citiesRequestVersion;
    debugPrint('[TECH_SERVICE_AREAS] loading cities for governorate: $governorateId');

    try {
      final cities = await widget.loadCities(governorateId);
      if (!mounted || requestVersion != _citiesRequestVersion) return;

      final matchingCities = cities.where((city) => city.governorateId == governorateId).toList();
      debugPrint('[TECH_SERVICE_AREAS] cities loaded: ${cities.length}');
      if (matchingCities.length != cities.length) {
        debugPrint('[TECH_SERVICE_AREAS] filtered cities whose governorateId did not match selected governorate');
      }

      setState(() {
        _cities = matchingCities;
        _loadingCities = false;
        _selectedCityId = null;
      });
    } catch (e) {
      if (!mounted || requestVersion != _citiesRequestVersion) return;
      setState(() {
        _cities = const [];
        _selectedCityId = null;
        _loadingCities = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _selectCity() async {
    final governorateId = _selectedGovernorateId;
    if (governorateId == null || _loadingCities || _cities.isEmpty || _adding) return;

    final validCities = _cities.where((city) => city.governorateId == governorateId).toList();
    final selectedId = await showTechnicianLocationPicker(
      context: context,
      title: 'اختر المدينة',
      selectedId: _selectedCityId,
      options: validCities
          .map((city) => TechnicianLocationOption(
                id: city.id,
                label: city.name ?? 'مدينة',
              ))
          .toList(),
    );
    if (!mounted || selectedId == null || _adding) return;

    final selectedCity = validCities.where((city) => city.id == selectedId).firstOrNull;
    final validSelection = selectedCity != null && selectedCity.governorateId == governorateId;

    debugPrint('[TECH_SERVICE_AREAS] city selected: $selectedId');
    debugPrint('[TECH_SERVICE_AREAS] city governorate: ${selectedCity?.governorateId}');
    debugPrint('[TECH_SERVICE_AREAS] selected governorate: $governorateId');
    debugPrint('[TECH_SERVICE_AREAS] validation result: $validSelection');

    if (!validSelection) {
      setState(() {
        _selectedCityId = null;
        _errorMessage = 'تعذر اختيار المدينة. أعد تحميل مدن المحافظة ثم حاول مرة أخرى.';
      });
      await _loadCities(governorateId);
      return;
    }

    setState(() {
      _selectedCityId = selectedId;
      _errorMessage = null;
    });
  }

  Future<void> _add() async {
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (_adding || governorateId == null || cityId == null) return;

    final selectedCity = _cities.where((city) => city.id == cityId).firstOrNull;
    final validSelection = selectedCity != null && selectedCity.governorateId == governorateId;

    debugPrint('[TECH_SERVICE_AREAS] city selected: $cityId');
    debugPrint('[TECH_SERVICE_AREAS] city governorate: ${selectedCity?.governorateId}');
    debugPrint('[TECH_SERVICE_AREAS] selected governorate: $governorateId');
    debugPrint('[TECH_SERVICE_AREAS] validation result: $validSelection');

    if (!validSelection) {
      setState(() {
        _selectedCityId = null;
        _errorMessage = 'المدينة لا تتبع المحافظة المحددة. اختر مدينة من القائمة الحالية.';
      });
      await _loadCities(governorateId);
      return;
    }

    if (widget.existingCityIds.contains(cityId)) {
      setState(() => _errorMessage = 'هذه المدينة مضافة بالفعل إلى مناطق الخدمة.');
      return;
    }

    setState(() {
      _adding = true;
      _errorMessage = null;
    });

    try {
      await widget.addArea(cityId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adding = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  String? _governorateLabel() {
    final id = _selectedGovernorateId;
    if (id == null) return null;
    final match = widget.governorates.where((item) => item.id == id).firstOrNull;
    return match?.name;
  }

  String? _cityLabel() {
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (governorateId == null || cityId == null) return null;
    final match = _cities.where((item) => item.id == cityId && item.governorateId == governorateId).firstOrNull;
    return match?.name;
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'إضافة منطقة خدمة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 12),
                  TechnicianLocationField(
                    label: 'المحافظة',
                    hint: 'اختر المحافظة',
                    valueLabel: _governorateLabel(),
                    enabled: !_adding,
                    loading: false,
                    onTap: _selectGovernorate,
                  ),
                  const SizedBox(height: 10),
                  TechnicianLocationField(
                    label: 'المدينة',
                    hint: 'اختر المدينة',
                    valueLabel: _cityLabel(),
                    enabled: _selectedGovernorateId != null && !_adding,
                    loading: _loadingCities,
                    onTap: _selectCity,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    _ServiceAreaMessage(message: _errorMessage!),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _adding || !_canAdd() ? null : _add,
                      child: _adding
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(
                              'إضافة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  bool _canAdd() {
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (governorateId == null || cityId == null || _loadingCities) return false;
    final city = _cities.where((item) => item.id == cityId).firstOrNull;
    return city != null && city.governorateId == governorateId && !widget.existingCityIds.contains(cityId);
  }
}

class _ServiceAreaMessage extends StatelessWidget {
  final String message;

  const _ServiceAreaMessage({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.error,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      );
}