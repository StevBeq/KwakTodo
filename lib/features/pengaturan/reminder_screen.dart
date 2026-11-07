library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/notifications/reminder_scheduler.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/round_back_button.dart';
import 'add_rule_sheet.dart';

/// Sub-layar Reminder Deadline (halaman baru di Pengaturan): toggle
/// utama + daftar aturan buatan user (H-N hari@jam / H-N jam) + form
/// tambah aturan inline. Setiap perubahan → SettingsProvider.
/// onReminderChanged → reschedule semua alarm (RULES §4.4).
class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onBack: onBack),
                  const SizedBox(height: 16),
                  _MainCard(
                    enabled: s.remEnabled,
                    onToggle: s.setReminderEnabled,
                  ),
                  if (s.remEnabled) ...[
                    const SizedBox(height: 16),
                    _RulesCard(s: s),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundBackButton(onTap: onBack),
        const SizedBox(width: 12),
        const Text(
          'Reminder Deadline',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// Kartu toggle utama.
class _MainCard extends StatelessWidget {
  const _MainCard({required this.enabled, required this.onToggle});

  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Aktifkan reminder',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          Switch(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}

/// Kartu daftar aturan + tombol tambah (membuka form inline di bawah).
class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.s});

  final SettingsProvider s;

  @override
  Widget build(BuildContext context) {
    final rules = s.remRules;
    final penuh = rules.length >= SettingsProvider.maxRules;

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
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Aturan kamu (${rules.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua tugas ber-deadline dikirim ingatan sesuai daftar ini. '
            'Hapus yang tidak perlu biar tidak berisik.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rules.length; i++)
            _RuleRow(rule: rules[i], onDelete: () => s.removeRemRule(i)),
          OutlinedButton.icon(
            onPressed: penuh
                ? null
                : () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: AppColors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      builder: (sheetCtx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
                        ),
                        child: const SingleChildScrollView(
                          child: AddRuleSheet(),
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(
              penuh
                  ? 'Maksimal ${SettingsProvider.maxRules} aturan'
                  : 'Tambah aturan',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              disabledForegroundColor: AppColors.muted,
              side: BorderSide.none,
              backgroundColor: AppColors.primarySoft,
              minimumSize: const Size.fromHeight(44),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris aturan: label tebal + deskripsi satu baris + hapus.
class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.onDelete});

  final RemRule rule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  rule.description,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
