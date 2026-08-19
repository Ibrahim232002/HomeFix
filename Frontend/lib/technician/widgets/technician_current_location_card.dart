import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../models/technician_profile_model.dart';
import '../../services/app_state_provider.dart';
import '../../repositories/technician_repository.dart';

class TechnicianCurrentLocationCard extends StatefulWidget {
  const TechnicianCurrentLocationCard({Key? key}) : super(key: key);

  @override
  State<TechnicianCurrentLocationCard> createState() => _TechnicianCurrentLocationCardState();
}

class _TechnicianCurrentLocationCardState extends State<TechnicianCurrentLocationCard> {
  final TechnicianRepository _technicianRepository = TechnicianRepository();

  int? _technicianId;
  int? _selectedGovernorateId;
  int? _selectedCityId;
  List<GovernorateDto> _governorates = [];
  List<CityDto> _cities = [];
  TechnicianProfileModel? _profile;

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
    final technicianId = int.tryParse(appState.currentTechProfile?.id ?? '0');

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
      _cities = [];

      if (_selectedGovernorateId != null) {
        final cities = await appState.loadCitiesForTechnician(_selectedGovernorateId!);
        if (!mounted) return;
        _cities = cities;
        if (cities.any((city) => city.id == profile?.currentCityId)) {
          _selectedCityId = profile?.currentCityId;
        }
      }

      if (!mounted) return;
      setState(() {
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

  Future<void> _loadCities(int governorateId) async {
    setState(() {
      _selectedCityId = null;
      _cities = [];
      _loadingCities = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final cities = await Provider.of<AppStateProvider>(context, listen: false)
          .loadCitiesForTechnician(governorateId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCities = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<void> _saveSelectedLocation() async {
    final technicianId = _technicianId;
    final governorateId = _selectedGovernorateId;
    final cityId = _selectedCityId;
    if (technicianId == null || governorateId == null || cityId == null) return;

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

  String? _currentLocationLabel() {
    if (_selectedGovernorateId == null || _selectedCityId == null) return null;
    final governorates = _governorates.where((item) => item.id == _selectedGovernorateId);
    final cities = _cities.where((item) => item.id == _selectedCityId);
    if (governorates.isEmpty || cities.isEmpty) return null;
    final governorate = governorates.first;
    final city = cities.first;
    return '${governorate.name ?? 'المحافظة'} - ${city.name ?? 'المدينة'}';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationLabel = _currentLocationLabel();
    final hasGps = _profile?.currentLatitude != null && _profile?.currentLongitude != null;

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
          else if (_errorMessage != null && _governorates.isEmpty)
            _InlineState(
              message: _errorMessage!,
              actionLabel: 'إعادة المحاولة',
              onPressed: _loadLocationData,
            )
          else ...[
            const Text('المحافظة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const SizedBox(height: 5),
            DropdownButtonFormField<int>(
              value: _selectedGovernorateId,
              decoration: const InputDecoration(hintText: 'اختر المحافظة'),
              items: _governorates
                  .map((governorate) => DropdownMenuItem<int>(
                        value: governorate.id,
                        child: Text(governorate.name ?? 'محافظة'),
                      ))
                  .toList(),
              onChanged: _saving || _locating
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _selectedGovernorateId = value);
                      _loadCities(value);
                    },
            ),
            const SizedBox(height: 10),
            const Text('المدينة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const SizedBox(height: 5),
            DropdownButtonFormField<int>(
              value: _selectedCityId,
              decoration: InputDecoration(
                hintText: 'اختر المدينة',
                suffixIcon: _loadingCities
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              items: _cities
                  .map((city) => DropdownMenuItem<int>(
                        value: city.id,
                        child: Text(city.name ?? 'مدينة'),
                      ))
                  .toList(),
              onChanged: _selectedGovernorateId == null || _loadingCities || _saving || _locating
                  ? null
                  : (value) => setState(() {
                        _selectedCityId = value;
                        _successMessage = null;
                        _errorMessage = null;
                      }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _saving || _locating || _selectedGovernorateId == null || _selectedCityId == null
                    ? null
                    : _saveSelectedLocation,
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
                  _locating ? 'جاري تحديد الموقع...' : 'تحديد موقعي الحالي',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (currentLocationLabel != null &&
                _profile?.currentGovernorateId == _selectedGovernorateId &&
                _profile?.currentCityId == _selectedCityId) ...[
              const SizedBox(height: 10),
              Text(
                '✓ موقعك محفوظ: $currentLocationLabel',
                style: const TextStyle(fontSize: 11, color: AppColors.technicianPrimary, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
              ),
            ],
            if (hasGps) ...[
              const SizedBox(height: 6),
              Text(
                'الموقع الجغرافي: ${_profile!.currentLatitude!.toStringAsFixed(5)}, ${_profile!.currentLongitude!.toStringAsFixed(5)}',
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
    );
  }
}

class _InlineState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const _InlineState({required this.message, required this.actionLabel, required this.onPressed});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _MessageBanner(message: message, isError: true),
          const SizedBox(height: 8),
          TextButton(onPressed: onPressed, child: Text(actionLabel, style: const TextStyle(fontFamily: 'Cairo'))),
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
