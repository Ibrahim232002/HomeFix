import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../services/app_state_provider.dart';

class TechnicianCurrentLocationCard extends StatefulWidget {
  const TechnicianCurrentLocationCard({Key? key}) : super(key: key);

  @override
  State<TechnicianCurrentLocationCard> createState() => _TechnicianCurrentLocationCardState();
}

class _TechnicianCurrentLocationCardState extends State<TechnicianCurrentLocationCard> {
  int? _selectedGovernorateId;
  int? _selectedCityId;
  String? _savedLocationLabel;
  List<GovernorateDto> _governorates = [];
  List<CityDto> _cities = [];
  bool _loading = true;
  bool _loadingCities = false;
  bool _saving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final governorates = await appState.loadGovernoratesForTechnician();
      if (!mounted) return;
      setState(() {
        _governorates = governorates;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCities(int governorateId) async {
    setState(() {
      _loadingCities = true;
      _cities = [];
      _selectedCityId = null;
    });
    try {
      final cities = await Provider.of<AppStateProvider>(context, listen: false)
          .loadCitiesForTechnician(governorateId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  void _saveSelectedCity() {
    if (_selectedGovernorateId == null || _selectedCityId == null) return;
    final governorate = _governorates.firstWhere((g) => g.id == _selectedGovernorateId);
    final city = _cities.firstWhere((c) => c.id == _selectedCityId);
    setState(() {
      _savedLocationLabel = '${governorate.name ?? 'المحافظة'} - ${city.name ?? 'المدينة'}';
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الموقع الأساسي للفني')),
    );
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
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
      await Provider.of<AppStateProvider>(context, listen: false)
          .updateTechnicianCurrentLocation(position.latitude, position.longitude);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إحداثيات موقعك الحالي بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final tech = appState.currentTechProfile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'موقع الفني',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختر المحافظة والمدينة التي تمثل موقعك الأساسي الحالي. هذا منفصل عن مناطق الخدمة التي تقبل فيها الطلبات.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            DropdownButtonFormField<int>(
              value: _selectedGovernorateId,
              decoration: const InputDecoration(labelText: 'المحافظة'),
              items: _governorates
                  .map((g) => DropdownMenuItem<int>(
                        value: g.id,
                        child: Text(g.name ?? 'محافظة'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedGovernorateId = value);
                _loadCities(value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedCityId,
              decoration: InputDecoration(
                labelText: 'المدينة',
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
                  .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name ?? 'مدينة'),
                      ))
                  .toList(),
              onChanged: _loadingCities
                  ? null
                  : (value) => setState(() => _selectedCityId = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ||
                            _selectedGovernorateId == null ||
                            _selectedCityId == null
                        ? null
                        : _saveSelectedCity,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(
                      'حفظ الموقع',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _locating ? null : _useGps,
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(
                      _locating ? 'جاري التحديد...' : 'تحديد موقعي الحالي',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_savedLocationLabel != null) ...[
            const SizedBox(height: 10),
            Text(
              'الموقع الأساسي المحفوظ: $_savedLocationLabel',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.technicianPrimary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ],
          if (tech?.currentLatitude != null && tech?.currentLongitude != null) ...[
            const SizedBox(height: 6),
            Text(
              'GPS: ${tech!.currentLatitude!.toStringAsFixed(5)}, ${tech.currentLongitude!.toStringAsFixed(5)}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
