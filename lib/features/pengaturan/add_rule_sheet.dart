library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/notifications/reminder_scheduler.dart';
import '../../core/utils/format.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';

const _dayOptions = [1, 2, 3, 5, 7, 10, 14];
const _jamBeforeOptions = [1, 2, 3, 6, 7, 12, 24, 48];

/// Sheet "Aturan baru": pilih mode (H-J hari pukul NN:00 / H-N jam),
/// angka jeda, jam (mode hari). Preview pakai computeSchedule pada
/// deadline contoh (+7 hari 12:00) — jujur nyambung ke engine jadwal.
class AddRuleSheet extends StatefulWidget {
  const AddRuleSheet({super.key});

  @override
  State<AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<AddRuleSheet> {
  RemUnit _unit = RemUnit.day;
  int _nDay = 1;
  int _nHour = 7;
  int _hour = 8;

  RemRule get _draft => RemRule(
    unit: _unit,
    n: _unit == RemUnit.day ? _nDay : _nHour,
    hour: _hour,
  );

  String get _preview {
    final raw = DateTime.now().add(const Duration(days: 7));
    final deadline = DateTime(raw.year, raw.month, raw.day, 12);
    final at = computeSchedule(
      deadline: deadline,
      isDone: false,
      rule: _draft,
      now: DateTime.now(),
    );
    if (at == null) {
      return 'Contoh ini sudah melewati momen notif — coba jeda lain.';
    }
    final hari = namaHari(at);
    return 'Contoh deadline ${fmtDeadline(deadline)} '
        '→ ingat hari $hari, ${fmtDeadline(at)}.';
  }

  Future<void> _simpan() async {
    await context.read<SettingsProvider>().addRemRule(_draft);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Aturan baru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _ModeChips(unit: _unit, onPick: (u) => setState(() => _unit = u)),
          const SizedBox(height: 12),
          if (_unit == RemUnit.day) ...[
            _Dropdown(
              label: 'INGAT SEBELUM',
              value: _nDay,
              options: _dayOptions,
              format: (v) => 'H-$v hari',
              onPick: (v) => setState(() => _nDay = v),
            ),
            const SizedBox(height: 10),
            _Dropdown(
              label: 'PADA JAM',
              value: _hour,
              options: SettingsProvider.remHourOptions,
              format: (v) => '${v.toString().padLeft(2, '0')}:00',
              onPick: (v) => setState(() => _hour = v),
            ),
          ] else
            _Dropdown(
              label: 'JEDA SEBELUM DEADLINE',
              value: _nHour,
              options: _jamBeforeOptions,
              format: (v) => 'H-$v jam',
              onPick: (v) => setState(() => _nHour = v),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _preview,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    side: const BorderSide(
                      color: AppColors.borderSoft,
                      width: 2,
                    ),
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _simpan,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text('Tambahkan ${_draft.label}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip pilihan mode aturan: Hari (tanggal − N, jam tetap) atau Jam
/// (momen deadline − N jam).
class _ModeChips extends StatelessWidget {
  const _ModeChips({required this.unit, required this.onPick});

  final RemUnit unit;
  final ValueChanged<RemUnit> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _chip(RemUnit.day, 'Hari', Icons.event_available_outlined),
        ),
        const SizedBox(width: 8),
        Expanded(child: _chip(RemUnit.hour, 'Jam', Icons.timer_outlined)),
      ],
    );
  }

  Widget _chip(RemUnit u, String label, IconData icon) {
    final aktif = u == unit;
    return InkWell(
      onTap: () => onPick(u),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: aktif ? AppColors.primary : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: aktif ? AppColors.surface : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: aktif ? AppColors.surface : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown bergaya prototype: field fill, label 11 bold muted.
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.format,
    required this.onPick,
  });

  final String label;
  final int value;
  final List<int> options;
  final String Function(int) format;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          DropdownButton<int>(
            value: value,
            items: [
              for (final o in options)
                DropdownMenuItem(value: o, child: Text(format(o))),
            ],
            onChanged: (v) {
              if (v != null) onPick(v);
            },
            underline: const SizedBox.shrink(),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.muted,
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            dropdownColor: AppColors.surface,
            isDense: true,
          ),
        ],
      ),
    );
  }
}
