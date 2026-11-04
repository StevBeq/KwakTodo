library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';

const _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// Nama hari notifikasi utk contoh "tugas kumpul Rabu" (proto updateRemPrev):
/// H-N sebelum Rabu (weekday 3) — H-2 → Senin, H-3 → Minggu, H-7 → Rabu.
String contohNotifHari(int h) {
  final target = ((3 - h - 1) % 7 + 7) % 7; // indeks 0 = Senin
  return _namaHari[target];
}

/// Kartu Reminder Deadline — prototype (222–243): judul + toggle,
/// dropdown "Ingat sebelum" & "Pada jam", preview primary-soft.
/// Nilai disimpan via SettingsProvider (DB s4; penjadwalan F5).
class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Reminder Deadline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Switch(
                value: s.remEnabled,
                onChanged: (v) =>
                    s.setReminder(enabled: v, days: s.remDays, hour: s.remHour),
              ),
            ],
          ),
          if (s.remEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dropdownDays(s)),
                const SizedBox(width: 12),
                Expanded(child: _dropdownHour(s)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Contoh: tugas kumpul Rabu → notifikasi '
              '${contohNotifHari(s.remDays)} '
              '${s.remHour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown gaya prototype (field fill + label 11 bold muted).
  Widget _dropdown(
    SettingsProvider s, {
    required String label,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int> onPick,
  }) {
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
            items: items,
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

  Widget _dropdownDays(SettingsProvider s) => _dropdown(
    s,
    label: 'INGAT SEBELUM',
    value: s.remDays,
    items: [
      for (final d in SettingsProvider.remDaysOptions)
        DropdownMenuItem(value: d, child: Text('H-$d')),
    ],
    onPick: (v) =>
        s.setReminder(enabled: s.remEnabled, days: v, hour: s.remHour),
  );

  Widget _dropdownHour(SettingsProvider s) => _dropdown(
    s,
    label: 'PADA JAM',
    value: s.remHour,
    items: [
      for (final h in SettingsProvider.remHourOptions)
        DropdownMenuItem(
          value: h,
          child: Text('${h.toString().padLeft(2, '0')}:00'),
        ),
    ],
    onPick: (v) =>
        s.setReminder(enabled: s.remEnabled, days: s.remDays, hour: v),
  );
}
