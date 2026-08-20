import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../models/technician_profile_model.dart';
import '../../repositories/technician_repository.dart';
import '../../services/app_state_provider.dart';
import 'technician_location_picker.dart';

class TechnicianCurrentLocationCard extends StatefulWidget {
  const TechnicianCurrentLocationCard({super.key});

  @override
  State<TechnicianCurrentLocationCard> createState() => _TechnicianCurrentLocationCardState();
}

class _TechnicianCurrentLocationCardState extends State<TechnicianCurrentLocationCard> {
  final TechnicianRepository _technicianRepository = TechnicianRepository();

  int? _technicianId;
  int? _selectedGovernorateId;
  int? _selectedCityId;
  List<GovernorateDto> _governorates = const [];
  List<CityDto> _cities = const [];
  TechnicianProfileModel? _profile;

  bool _loading = true;
  bool _loadingCities = false;
  bool _saving = false;
  bool _locating = false;
  String? _errorMessage;
  String? _successMessage;
  int _citiesRequestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final technicianId = int.tryParse(appState.currentTechProfile?.id ?? '');

    if (technicianId == null || technicianId <= 0) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'تعذر تحديد ملف الفني.';
      });
      return;
    }

    try {
      final profile = await _technicianRepository.getTechnicianById(technicianId.toString());
      if (!mounted) return;

      final governorates = await appState.loadGovernoratesForTechnician();
      if (!mounted) return;

      _technicianId = technicianId;
      _profile = profile;
      _governorates = governorates;
      _selectedGovernorateId = profile?.currentGovernorateId;
      _selectedCityId = null;
      _cities = const [];
      _errorMessage = null;

      final governorateId = profile?.currentGovernorateId;
      final savedCityId = profile?.currentCityId;
      if (governorateId != null) {
        await _loadCitiesForGovernorate(
          governorateId,
          restoreCityId: savedCityId,
          clearError: false,
        );
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _loadCitiesForGovernorate(
    int governorateId, {
    int? restoreCityId,
    bool clearError = true,
  }) async {
    final requestVersion = ++_citiesRequestVersion;

    if (mounted) {
      setState(() {
        _loadingCities = true;
        _cities = const [];
        _selectedCityId = null;
        if (clearError) {
          _errorMessage = null;
          _successMessage = null;
        }
      });
    }

    debugPrint('[TECH_LOCATION] loading cities for governorate: $governorateId');

    try {
      final cities = await Provider.of<AppStateProvider>(context, listen: false)
          .loadCitiesForTechnician(governorateId);
      if (!mounted || requestVersion != _citiesRequestVersion) return;

      final matchingCities = cities.where((city) => city.governorateId == governorateId).toList();
      debugPrint('[TECH_LOCATION] cities loaded: ${cities.length}');
      if (matchingCities.length != cities.length) {
        debugPrint(
          '[TECH_LOCATION] filtered cities whose governorateId did not match selected governorate',
        );
      }

      final restoredCityIsValid = restoreCityId != null &&
          matchingCities.any((city) => city.id == restoreCityId && city.governorateId == governorateId);

      if (restoreCityId != null && !restoredCityIsValid) {
        debugPrint('[TECH_LOCATION] saved city rejected because city.governorateId does not match selected governorate');
      }

      setState(() {
        _cities = matchingCities;
        _selectedCityId = restoredCityIsValid ? restoreCityId : null;
        _loadingCities = false;
        if (restoreCityId != null && !restoredCityIsValid) {
          _errorMessage = 'المدينة المحفوظة لا تتبع المحافظة الحالية. اختر المدينة مرة أخرى.';
        }
      });

      if (restoreCityId != null) {
        debugPrint('[TECH_LOCATION] city selected: ${restoredCityIsValid ? restoreCityId : 'null'}');
        debugPrint('[TECH_LOCATION] selected governorate: $governorateId');
        debugPrint('[TECH_LOCATION] validation result: $restoredCityIsValid');
      }
    } catch (e) {
      if (!mounted || requestVersion != _citiesRequestVersion) return;
      setState(() {
        _loadingCities = false;
        _cities = const [];
        _selectedCityId = null;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _selectGovernorate() async {
    final selectedId = await showTechnicianLocationPicker(
      context: context,
      title: 'اختر المحافظة',
      selectedId: _selectedGovernorateId,
      options: _governorates
          .map((governorate) => TechnicianLocationOption(
                id: governorate.id,
                label: governorate.name ?? 'محافظة',
              ))
          .toList(),
    );
    if (!mounted || selectedId == null) return;

    debugPrint('[TECH_LOCATION] governorate selected: $selectedId');
    setState(() {
      _selectedGovernorateId = selectedId;
      _selectedCityId = null;
      _successMessage = null;
      _errorMessage = null;
    });

    await _loadCitiesForGovernorate(selectedId);
  }

  Future<void> _selectCity() async {
    final governorateId = _selectedGovernorateId;
    if (governorateId == null || _loadingCities || _cities.isEmpty) return;

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
    if (!mounted || selectedId == null) return;

    final selectedCity = validCities.where((city) => city.id == selectedId).firstOrNull;
    final validSelection = selectedCity != null && selectedCity.governorateId == governorateId;

    debugPrint('[TECH_LOCATION] city selected: $selectedId');
    debugPrint('[TECH_LOCATION] city governorate: ${selectedCity?.governorateId}');
    debugPrint('[TECH_LOCATION] selected governorate: $governorateId');
    debugPrint('[TECH_LOCATION] validation result: $validSelection');

    if (!validSelection) {
      setState(() {
        _selectedCityId = null;
        _errorMessage = 'تعذر اختيار المدينة. أعد تحميل مدن المحافظة ثم حاول مرة أخرى.';
      });
      await _loadCitiesForGovernorate(governorateId);
      return;
    }

    setState(() {
      _selectedCityId = selectedId;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  bool _hasValidCitySelection() {
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (governorateId == null || cityId == null) return false;

    final matchingCity = _cities.where((city) => city.id == cityId).firstOrNull;
    final valid = matchingCity != null && matchingCity.governorateId == governorateId;
    debugPrint('[TECH_LOCATION] selected governorate: $governorateId');
    debugPrint('[TECH_LOCATION] city selected: $cityId');
    debugPrint('[TECH_LOCATION] city governorate: ${matchingCity?.governorateId}');
    debugPrint('[TECH_LOCATION] validation result: $valid');
    return valid;
  }

  Future<void> _saveSelectedLocation() async {
    final technicianId = _technicianId;
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;

    if (technicianId == null || governorateId == null || cityId == null) return;

    if (!_hasValidCitySelection()) {
      setState(() {
        _selectedCityId = null;
        _errorMessage = 'المدينة لا تتبع المحافظة المحددة. اختر مدينة من القائمة الحالية.';
      });
      await _loadCitiesForGovernorate(governorateId);
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updated = await _technicianRepository.updateCurrentLocation(
        technicianId: technicianId,
        currentGovernorateId: governorateId,
        currentCityId: cityId,
        currentLatitude: _profile?.currentLatitude,
        currentLongitude: _profile?.currentLongitude,
      );
      if (!mounted) return;

      setState(() {
        _profile = updated;
        _saving = false;
        _successMessage = 'تم حفظ موقعك الحالي';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _useGps() async {
    final technicianId = _technicianId;
    if (technicianId == null) return;

    setState(() {
      _locating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('فعّل خدمة الموقع في الهاتف ثم أعد المحاولة.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('لم يتم منح صلاحية الموقع. يمكنك اختيار المحافظة والمدينة يدوياً.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // GPS deliberately uses the last persisted manual location, not the
      // potentially unsaved dropdown selection.
      final updated = await _technicianRepository.updateCurrentLocation(
        technicianId: technicianId,
        currentGovernorateId: _profile?.currentGovernorateId,
        currentCityId: _profile?.currentCityId,
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );
      if (!mounted) return;

      setState(() {
        _profile = updated;
        _locating = false;
        _successMessage = 'تم تحديث موقعك الجغرافي';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  String? _governorateLabel() {
    final id = _selectedGovernorateId;
    if (id == null) return null;
    final match = _governorates.where((item) => item.id == id).firstOrNull;
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
  Widget build(BuildContext context) {
    final hasGps = _profile?.currentLatitude != null && _profile?.currentLongitude != null;
    final locationIsPersisted = _profile?.currentGovernorateId == _selectedGovernorateId &&
        _profile?.currentCityId == _selectedCityId &&
        _selectedGovernorateId != null &&
        _selectedCityId != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'موقع الفني الحالي',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 4),
            const Text(
              'حدد المحافظة والمدينة التي تتواجد فيها حاليًا.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null && _governorates.isEmpty)
              _InlineLocationState(
                message: _errorMessage!,
                actionLabel: 'إعادة المحاولة',
                onPressed: _loadLocationData,
              )
            else ...[
              TechnicianLocationField(
                label: 'المحافظة',
                hint: 'اختر المحافظة',
                valueLabel: _governorateLabel(),
                enabled: !_saving && !_locating,
                loading: false,
                onTap: _selectGovernorate,
              ),
              const SizedBox(height: 10),
              TechnicianLocationField(
                label: 'المدينة',
                hint: 'اختر المدينة',
                valueLabel: _cityLabel(),
                enabled: _selectedGovernorateId != null && !_saving && !_locating,
                loading: _loadingCities,
                onTap: _selectCity,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _saving || _locating || !_hasValidCitySelection()
                      ? null
                      : _saveSelectedLocation,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined, size: 19),
                  label: const Text(
                    'حفظ الموقع',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: _locating || _saving ? null : _useGps,
                  icon: const Icon(Icons.my_location_rounded, size: 19),
                  label: Text(
                    _locating ? 'جاري تحديد الموقع...' : 'تحديث الموقع الحالي',
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (locationIsPersisted) ...[
                const SizedBox(height: 10),
                Text(
                  '✓ موقعك محفوظ: ${_governorateLabel()} - ${_cityLabel()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.technicianPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
              if (hasGps) ...[
                const SizedBox(height: 6),
                Text(
                  'GPS: ${_profile!.currentLatitude!.toStringAsFixed(5)}, ${_profile!.currentLongitude!.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'Cairo'),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 8),
                _MessageBanner(message: _successMessage!, isError: false),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                _MessageBanner(message: _errorMessage!, isError: true),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineLocationState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const _InlineLocationState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _MessageBanner(message: message, isError: true),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onPressed,
            child: Text(actionLabel, style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      );
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isError ? AppColors.errorLight : AppColors.technicianLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 11,
            color: isError ? AppColors.error : AppColors.technicianPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      );
}
