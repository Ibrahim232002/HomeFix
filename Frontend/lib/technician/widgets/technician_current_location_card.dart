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
  final TechnicianRepository _repository = TechnicianRepository();

  TechnicianProfileModel? _profile;
  List<GovernorateDto> _governorates = const [];
  List<CityDto> _cities = const [];

  int? _technicianId;
  int? _selectedGovernorateId;
  int? _selectedCityId;
  int _citiesRequestVersion = 0;

  bool _loading = true;
  bool _loadingCities = false;
  bool _saving = false;
  bool _locating = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final profile = appState.currentTechProfile;
    final userId = appState.currentUser?.id;

    if (profile == null || profile.id.isEmpty || userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'تعذر تحديد ملف الفني المرتبط بالحساب.';
      });
      return;
    }

    if (profile.userId != userId) {
      debugPrint('[TECH_PROFILE_RESOLUTION] Current Location profile mismatch');
      debugPrint('userId: $userId');
      debugPrint('technicianProfileId: ${profile.id}');
      debugPrint('profile.userId: ${profile.userId}');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'عدم تطابق هوية ملف الفني مع حساب المستخدم.';
      });
      return;
    }

    final technicianId = int.tryParse(profile.id);
    if (technicianId == null || technicianId <= 0) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'معرف ملف الفني غير صالح.';
      });
      return;
    }

    debugPrint('[TECH_PROFILE_RESOLUTION] Current Location using central profile');
    debugPrint('userId: $userId');
    debugPrint('technicianProfileId: ${profile.id}');
    debugPrint('profile.userId: ${profile.userId}');

    try {
      final governorates = await appState.loadGovernoratesForTechnician();
      if (!mounted) return;

      _profile = profile;
      _technicianId = technicianId;
      _governorates = governorates;
      _selectedGovernorateId = profile.currentGovernorateId;
      _selectedCityId = null;
      _cities = const [];
      _errorMessage = null;
      _successMessage = null;

      final savedGovernorateId = profile.currentGovernorateId;
      final savedCityId = profile.currentCityId;
      if (savedGovernorateId != null) {
        await _loadCitiesForGovernorate(
          savedGovernorateId,
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

    setState(() {
      _loadingCities = true;
      _cities = const [];
      _selectedCityId = null;
      if (clearError) {
        _errorMessage = null;
        _successMessage = null;
      }
    });

    debugPrint('[TECH_CURRENT_LOCATION] loading cities for governorate: $governorateId');

    try {
      final cities = await Provider.of<AppStateProvider>(context, listen: false)
          .loadCitiesForTechnician(governorateId);

      if (!mounted || requestVersion != _citiesRequestVersion) return;

      final matchingCities = cities
          .where((city) => city.isActive && city.governorateId == governorateId)
          .toList();

      debugPrint('[TECH_CURRENT_LOCATION] cities loaded: ${cities.length}');
      debugPrint('[TECH_CURRENT_LOCATION] matching active cities: ${matchingCities.length}');

      final restoredCityIsValid = restoreCityId != null && matchingCities.any(
        (city) => city.id == restoreCityId && city.governorateId == governorateId,
      );

      if (restoreCityId != null && !restoredCityIsValid) {
        debugPrint('[TECH_CURRENT_LOCATION] saved city rejected by ID relationship');
      }

      setState(() {
        _cities = matchingCities;
        _selectedCityId = restoredCityIsValid ? restoreCityId : null;
        _loadingCities = false;
        if (restoreCityId != null && !restoredCityIsValid) {
          _errorMessage = 'المدينة المحفوظة لا تتبع المحافظة الحالية. اختر المدينة مرة أخرى.';
        }
      });
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
          .where((governorate) => governorate.isActive)
          .map((governorate) => TechnicianLocationOption(
                id: governorate.id,
                label: governorate.name ?? 'محافظة',
              ))
          .toList(),
    );

    if (!mounted || selectedId == null) return;

    debugPrint('[TECH_CURRENT_LOCATION] governorate selected: $selectedId');

    setState(() {
      _selectedGovernorateId = selectedId;
      _selectedCityId = null;
      _cities = const [];
      _errorMessage = null;
      _successMessage = null;
    });

    await _loadCitiesForGovernorate(selectedId);
  }

  Future<void> _selectCity() async {
    final governorateId = _selectedGovernorateId;
    if (governorateId == null || _loadingCities || _cities.isEmpty) return;

    final validCities = _cities
        .where((city) => city.isActive && city.governorateId == governorateId)
        .toList();

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

    debugPrint('[TECH_CURRENT_LOCATION] city selected: $selectedId');
    debugPrint('[TECH_CURRENT_LOCATION] city governorate: ${selectedCity?.governorateId}');
    debugPrint('[TECH_CURRENT_LOCATION] selected governorate: $governorateId');
    debugPrint('[TECH_CURRENT_LOCATION] validation result: $validSelection');

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

  CityDto? _selectedCity() {
    final cityId = _selectedCityId;
    final governorateId = _selectedGovernorateId;
    if (cityId == null || governorateId == null) return null;
    return _cities.where((city) => city.id == cityId).firstOrNull;
  }

  GovernorateDto? _selectedGovernorate() {
    final governorateId = _selectedGovernorateId;
    if (governorateId == null) return null;
    return _governorates.where((governorate) => governorate.id == governorateId).firstOrNull;
  }

  bool _hasValidCitySelection() {
    final governorateId = _selectedGovernorateId;
    final city = _selectedCity();
    final valid = governorateId != null && city != null && city.governorateId == governorateId;

    debugPrint('[TECH_CURRENT_LOCATION] selected governorate: $governorateId');
    debugPrint('[TECH_CURRENT_LOCATION] city selected: ${city?.id}');
    debugPrint('[TECH_CURRENT_LOCATION] city governorate: ${city?.governorateId}');
    debugPrint('[TECH_CURRENT_LOCATION] validation result: $valid');

    return valid;
  }

  Future<void> _saveSelectedLocation() async {
    final technicianId = _technicianId;
    final governorate = _selectedGovernorate();
    final city = _selectedCity();

    debugPrint('[TECH_CURRENT_LOCATION] BEFORE SAVE');
    debugPrint('technicianId: $technicianId');
    debugPrint('selectedGovernorateId: ${_selectedGovernorateId}');
    debugPrint('selectedCityId: ${_selectedCityId}');
    debugPrint('selectedCity.governorateId: ${city?.governorateId}');
    debugPrint('selectedCity.name: ${city?.name}');
    debugPrint('selectedGovernorate.name: ${governorate?.name}');

    if (technicianId == null || governorate == null || city == null) return;

    final valid = city.governorateId == governorate.id;
    debugPrint('[TECH_CURRENT_LOCATION] validation result: $valid');

    if (!valid) {
      setState(() {
        _selectedCityId = null;
        _errorMessage = 'المدينة لا تتبع المحافظة المحددة. اختر مدينة من القائمة الحالية.';
      });
      await _loadCitiesForGovernorate(governorate.id);
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updated = await _repository.updateCurrentLocation(
        technicianId: technicianId,
        currentGovernorateId: governorate.id,
        currentCityId: city.id,
        currentLatitude: _profile?.currentLatitude,
        currentLongitude: _profile?.currentLongitude,
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _selectedGovernorateId = updated.currentGovernorateId;
        _selectedCityId = updated.currentCityId;
        _saving = false;
        _errorMessage = null;
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

    final persistedGovernorateId = _profile?.currentGovernorateId;
    final persistedCityId = _profile?.currentCityId;

    debugPrint('[TECH_CURRENT_LOCATION] GPS preserving persisted IDs:');
    debugPrint('currentGovernorateId: $persistedGovernorateId');
    debugPrint('currentCityId: $persistedCityId');

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
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('لم يتم منح صلاحية الموقع. يمكنك اختيار المحافظة والمدينة يدويًا.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final updated = await _repository.updateCurrentLocation(
        technicianId: technicianId,
        currentGovernorateId: persistedGovernorateId,
        currentCityId: persistedCityId,
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;
        _selectedGovernorateId = updated.currentGovernorateId;
        _selectedCityId = updated.currentCityId;
        _locating = false;
        _errorMessage = null;
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

  String _friendlyError(Object error) => error.toString().replaceFirst('Exception: ', '').trim();

  String? _governorateLabel() => _selectedGovernorate()?.name;

  String? _cityLabel() {
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (governorateId == null || cityId == null) return null;
    return _cities.where((city) => city.id == cityId && city.governorateId == governorateId).firstOrNull?.name;
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
          else if (_governorates.isEmpty && _errorMessage != null)
            _LocationMessage(
              message: _errorMessage!,
              isError: true,
              action: TextButton(
                onPressed: _loadLocationData,
                child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
              ),
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
                onPressed: _saving || _locating || !_hasValidCitySelection() ? null : _saveSelectedLocation,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 19),
                label: const Text('حفظ الموقع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
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
                style: const TextStyle(fontSize: 11, color: AppColors.technicianPrimary, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
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
              _LocationMessage(message: _successMessage!, isError: false),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              _LocationMessage(message: _errorMessage!, isError: true),
            ],
          ],
        ],
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  final String message;
  final bool isError;
  final Widget? action;

  const _LocationMessage({required this.message, required this.isError, this.action});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isError ? AppColors.errorLight : AppColors.technicianLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 11,
                color: isError ? AppColors.error : AppColors.technicianPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
            if (action != null) action!,
          ],
        ),
      );
}
