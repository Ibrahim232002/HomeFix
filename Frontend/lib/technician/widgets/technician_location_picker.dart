import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

T? firstOrNull<T>(Iterable<T> values) => values.isEmpty ? null : values.first;

class TechnicianLocationOption {
  final int id;
  final String label;

  const TechnicianLocationOption({required this.id, required this.label});
}

Future<int?> showTechnicianLocationPicker({
  required BuildContext context,
  required String title,
  required List<TechnicianLocationOption> options,
  required int? selectedId,
  String emptyMessage = 'لا توجد خيارات متاحة',
}) {
  final uniqueOptions = <int, TechnicianLocationOption>{
    for (final option in options) option.id: option,
  }.values.toList(growable: false);

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: uniqueOptions.isEmpty
                      ? Center(
                          child: Text(
                            emptyMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: uniqueOptions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (itemContext, index) {
                            final option = uniqueOptions[index];
                            final selected = option.id == selectedId;
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                minVerticalPadding: 8,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                                title: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                leading: Icon(
                                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: selected ? AppColors.technicianPrimary : AppColors.textMuted,
                                ),
                                trailing: selected
                                    ? const Icon(Icons.check_rounded, color: AppColors.technicianPrimary, size: 20)
                                    : null,
                                onTap: () => Navigator.of(sheetContext).pop(option.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TechnicianLocationField extends StatelessWidget {
  final String label;
  final String hint;
  final String? valueLabel;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const TechnicianLocationField({
    super.key,
    required this.label,
    required this.hint,
    required this.valueLabel,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = valueLabel != null && valueLabel!.trim().isNotEmpty;
    final active = enabled && !loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 5),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: active ? onTap : null,
            child: InputDecorator(
              isEmpty: !hasValue,
              decoration: InputDecoration(
                enabled: active,
                hintText: hint,
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              child: Text(
                hasValue ? valueLabel! : hint,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
