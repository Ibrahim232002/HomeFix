import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../models/technician_service_area_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianServiceAreaCard extends StatefulWidget {
  const TechnicianServiceAreaCard({Key? key}) : super(key: key);

  @override
  State<TechnicianServiceAreaCard> createState() => _TechnicianServiceAreaCardState();
}

class _TechnicianServiceAreaCardState extends State<TechnicianServiceAreaCard> {
  List<GovernorateDto> _governorates = [];
  bool _loading = true;
  bool _loadingAreas = false;
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
      await appState.loadServiceAreas();
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
    setState(() {
      _removingCityId = cityId;
      _errorMessage = null;
    });
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
    if (_governorates.isEmpty) return;
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddServiceAreaSheet(
        governorates: _governorates,
        loadCities: appState.loadCitiesForTechnician,
        addArea: appState.addTechnicianServiceArea,
      ),
    );

    if (!mounted) return;
    await appState.loadServiceAreas();
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
                onPressed: _loadingAreas ? null : _showAddAreaSheet,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text(
                  'إضافة منطقة خدمة',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 11, color: AppColors.error, fontFamily: 'Cairo'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ServiceAreaChip extends StatelessWidget {
  final TechnicianServiceAreaModel area;
  final Future<String> Function(int cityId) getCityName;
  final bool removing;
  final VoidCallback onRemove;

  const _ServiceAreaChip({
    required this.area,
    required this.getCityName,
    required this.removing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: getCityName(area.cityId),
        builder: (context, snapshot) => Container(
          padding: const EdgeInsetsDirectional.only(start: 11, end: 6, top: 6, bottom: 6),
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
              const SizedBox(width: 4),
              SizedBox(
                width: 24,
                height: 24,
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
  final Future<List<CityDto>> Function(int governorateId) loadCities;
  final Future<void> Function(int cityId) addArea;

  const _AddServiceAreaSheet({
    required this.governorates,
    required this.loadCities,
    required this.addArea,
  });

  @override
  State<_AddServiceAreaSheet> createState() => _AddServiceAreaSheetState();
}

class _AddServiceAreaSheetState extends State<_AddServiceAreaSheet> {
  int? _selectedGovernorateId;
  int? _selectedCityId;
  List<CityDto> _cities = [];
  bool _loadingCities = false;
  bool _adding = false;
  String? _errorMessage;

  Future<void> _selectGovernorate(int governorateId) async {
    setState(() {
      _selectedGovernorateId = governorateId;
      _selectedCityId = null;
      _cities = [];
      _loadingCities = true;
      _errorMessage = null;
    });

    try {
      final cities = await widget.loadCities(governorateId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCities = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  Future<void> _add() async {
    final cityId = _selectedCityId;
    if (cityId == null || _adding) return;

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
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'إضافة منطقة خدمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                const Text('المحافظة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                const SizedBox(height: 5),
                DropdownButtonFormField<int>(
                  value: _selectedGovernorateId,
                  decoration: const InputDecoration(hintText: 'اختر المحافظة'),
                  items: widget.governorates
                      .map((governorate) => DropdownMenuItem<int>(
                            value: governorate.id,
                            child: Text(governorate.name ?? 'محافظة'),
                          ))
                      .toList(),
                  onChanged: _adding ? null : (value) {
                    if (value != null) _selectGovernorate(value);
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
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem<int>(
                            value: city.id,
                            child: Text(city.name ?? 'مدينة'),
                          ))
                      .toList(),
                  onChanged: _selectedGovernorateId == null || _loadingCities || _adding
                      ? null
                      : (value) => setState(() => _selectedCityId = value),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: const TextStyle(fontSize: 11, color: AppColors.error, fontFamily: 'Cairo')),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _adding || _selectedCityId == null ? null : _add,
                    child: _adding
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('إضافة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
