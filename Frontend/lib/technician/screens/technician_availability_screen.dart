import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';
import '../../services/app_state_provider.dart';

class TechnicianAvailabilityScreen extends StatefulWidget {
  const TechnicianAvailabilityScreen({super.key});

  @override
  State<TechnicianAvailabilityScreen> createState() => _TechnicianAvailabilityScreenState();
}

class _TechnicianAvailabilityScreenState extends State<TechnicianAvailabilityScreen> {
  final ITechnicianRepository _repo = TechnicianRepository();
  List<TechnicianAvailabilityDto> _items = const [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  int? get _techId => int.tryParse(
        context.read<AppStateProvider>().currentTechProfile?.id ??
            context.read<AppStateProvider>().currentUser?.id ??
            '',
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _techId;
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.getAvailabilities(id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _day(int day) =>
      const ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'][day.clamp(0, 6).toInt()];

  Future<void> _add() async {
    final id = _techId;
    if (id == null || _busy) return;

    int day = 0;
    TimeOfDay? start;
    TimeOfDay? end;
    bool enabled = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة وقت عمل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: day,
                decoration: const InputDecoration(labelText: 'اليوم'),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(value: i, child: Text(_day(i))),
                ),
                onChanged: (value) => setDialogState(() => day = value ?? 0),
              ),
              const SizedBox(height: AppDesignTokens.space3),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('من'),
                      subtitle: Text(start?.format(context) ?? 'اختر'),
                      onTap: () async {
                        final value = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (value != null) {
                          setDialogState(() => start = value);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('إلى'),
                      subtitle: Text(end?.format(context) ?? 'اختر'),
                      onTap: () async {
                        final value = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 17, minute: 0),
                        );
                        if (value != null) {
                          setDialogState(() => end = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: enabled,
                onChanged: (value) => setDialogState(() => enabled = value),
                title: const Text('متاح للحجز'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: start == null || end == null
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || start == null || end == null) return;

    final startValue = start!;
    final endValue = end!;
    final startMinutes = startValue.hour * 60 + startValue.minute;
    final endMinutes = endValue.hour * 60 + endValue.minute;
    if (startMinutes >= endMinutes) {
      setState(() => _error = 'يجب أن يكون وقت البداية قبل النهاية.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _repo.createAvailability(
        CreateTechnicianAvailabilityRequest(
          technicianId: id,
          dayOfWeek: day,
          startTime: '${startValue.hour.toString().padLeft(2, '0')}:${startValue.minute.toString().padLeft(2, '0')}:00',
          endTime: '${endValue.hour.toString().padLeft(2, '0')}:${endValue.minute.toString().padLeft(2, '0')}:00',
          isAvailable: enabled,
        ),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أوقات التوفر')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.add),
        label: const Text('إضافة وقت'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppResponsive.content(
              context,
              child: _loading
                  ? const HomeFixLoadingList(itemCount: 4)
                  : _error != null
                      ? HomeFixErrorState(
                          title: 'تعذر تحميل أوقات التوفر',
                          message: _error,
                          onRetry: _load,
                        )
                      : _items.isEmpty
                          ? const SizedBox(
                              height: 420,
                              child: HomeFixEmptyState(
                                icon: Icons.schedule_outlined,
                                title: 'لا توجد أوقات مسجلة',
                                message: 'أضف فترات العمل التي تريد استقبال الحجوزات خلالها.',
                              ),
                            )
                          : Column(
                              children: _items
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppDesignTokens.space3,
                                      ),
                                      child: HomeFixCard(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _day(item.dayOfWeek),
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('${item.startTime} → ${item.endTime}'),
                                                ],
                                              ),
                                            ),
                                            HomeFixStatusChip(
                                              label: item.isAvailable ? 'متاح' : 'متوقف',
                                              tone: item.isAvailable
                                                  ? HomeFixStatusTone.success
                                                  : HomeFixStatusTone.neutral,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
