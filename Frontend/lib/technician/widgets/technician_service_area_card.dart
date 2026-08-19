import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../services/app_state_provider.dart';

class TechnicianServiceAreaCard extends StatefulWidget {
  const TechnicianServiceAreaCard({Key? key}) : super(key: key);

  @override
  State<TechnicianServiceAreaCard> createState() => _TechnicianServiceAreaCardState();
}

class _TechnicianServiceAreaCardState extends State<TechnicianServiceAreaCard> {
  int? _selectedGovernorateId;
  int? _selectedCityId;
  List<GovernorateDto> _governorates = [];
  List<CityDto> _cities = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final client = appState;
      final response = await client.loadGovernoratesForTechnician();
      if (!mounted) return;
      setState(() {
        _governorates = response;
        _loading = false;
      });
      await appState.loadServiceAreas();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCities(int governorateId) async {
    try {
      final cities = await Provider.of<AppStateProvider>(context, listen: false).loadCitiesForTechnician(governorateId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _selectedCityId = null;
      });
    } catch (_) {
      if (mounted) setState(() => _cities = []);
    }
  }

  Future<void> _addArea() async {
    final cityId = _selectedCityId;
    if (cityId == null) return;
    setState(() => _saving = true);
    try {
      await Provider.of<AppStateProvider>(context, listen: false).addTechnicianServiceArea(cityId);
      if (!mounted) return;
      setState(() => _selectedCityId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة منطقة الخدمة بنجاح')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final areas = appState.serviceAreas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('مناطق الخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
        const SizedBox(height: 6),
        const Text('اختَر المدن التي تقدم فيها الخدمة. هذه المناطق هي أساس مطابقة طلبات العملاء.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo')),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          DropdownButtonFormField<int>(
            value: _selectedGovernorateId,
            decoration: const InputDecoration(labelText: 'المحافظة'),
            items: _governorates.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name ?? 'محافظة'))).toList(),
            onChanged: (value) {
              setState(() => _selectedGovernorateId = value);
              if (value != null) _loadCities(value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedCityId,
            decoration: const InputDecoration(labelText: 'المدينة'),
            items: _cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name ?? 'مدينة'))).toList(),
            onChanged: (value) => setState(() => _selectedCityId = value),
          ),
          const SizedBox(height: 10),
          Align(alignment: AlignmentDirectional.centerStart, child: ElevatedButton.icon(onPressed: _saving ? null : _addArea, icon: const Icon(Icons.add_location_alt_outlined), label: const Text('إضافة منطقة خدمة', style: TextStyle(fontFamily: 'Cairo')))),
        ],
        const SizedBox(height: 14),
        if (areas.isEmpty)
          const Text('لم يتم تحديد مناطق خدمة بعد.', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areas.map((area) => Chip(
              label: FutureBuilder<String>(future: Provider.of<AppStateProvider>(context, listen: false).getCityName(area.cityId), builder: (_, snapshot) => Text(snapshot.data ?? 'مدينة ${area.cityId}', style: const TextStyle(fontFamily: 'Cairo'))),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => Provider.of<AppStateProvider>(context, listen: false).removeTechnicianServiceArea(area.cityId),
            )).toList(),
          ),
      ]),
    );
  }
}
