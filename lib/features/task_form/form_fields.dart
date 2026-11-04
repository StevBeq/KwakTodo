library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../core/utils/format.dart';
import '../../shared/theme/app_theme.dart';

/// Field-field TaskFormSheet — dipisah supaya tiap file ≤300 baris
/// (RULES §1.5). Semua stateless; state ada di sheet induk.

const _kLabelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: AppColors.muted,
);

/// DEADLINE — tap membuka date+time picker; chip x untuk mengosongkan.
class DeadlineField extends StatelessWidget {
  const DeadlineField({super.key, this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final today = DateTime.now();
    final current = value;
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2),
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : const TimeOfDay(hour: 23, minute: 59),
    );
    if (!context.mounted) return;
    final TimeOfDay? t =
        time ?? (current == null ? null : TimeOfDay.fromDateTime(current));
    final adjusted = DateTime(
      date.year,
      date.month,
      date.day,
      t?.hour ?? 0,
      t?.minute ?? 0,
    );
    // nilai identik (mis. user cancel time dengan kondisi sama) → tetap set.
    onChanged(adjusted);
  }

  @override
  Widget build(BuildContext context) {
    final d = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DEADLINE', style: _kLabelStyle),
        const SizedBox(height: 6),
        Material(
          color: AppColors.fieldFill,
          borderRadius: AppRadius.input,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pick(context),
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        d == null ? 'Pilih tanggal & jam' : fmtDeadline(d),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: d == null ? AppColors.hint : AppColors.ink,
                        ),
                      ),
                    ),
                    if (d != null)
                      InkWell(
                        onTap: () => onChanged(null),
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// PRIORITAS — dropdown (sesuai prototype: select bulat abu).
class PriorityField extends StatelessWidget {
  const PriorityField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Priority value;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRIORITAS', style: _kLabelStyle),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: AppRadius.input,
          ),
          height: 44,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Priority>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.muted,
              ),
              items: [
                for (final p in Priority.values)
                  DropdownMenuItem(value: p, child: Text(priorityLabels[p]!)),
              ],
              onChanged: (p) {
                if (p != null) onChanged(p);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// KATEGORI — chips pastel saat terpilih, outline saat idle (DESIGN §5).
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Category value;
  final ValueChanged<Category> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in Category.values)
          InkWell(
            onTap: () => onChanged(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c == value
                    ? categoryColorPairs[c]!.$1
                    : AppColors.surface,
                borderRadius: AppRadius.chip,
                border: Border.all(
                  color: c == value ? Colors.transparent : AppColors.divider,
                  width: 2,
                ),
              ),
              child: Text(
                categoryLabels[c]!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c == value
                      ? categoryColorPairs[c]!.$2
                      : AppColors.muted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
