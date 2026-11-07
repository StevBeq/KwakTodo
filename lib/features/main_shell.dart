library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ai_capture/ai_capture_flow.dart';
import 'beranda/beranda_screen.dart';
import 'jadwal/jadwal_screen.dart';
import 'pengaturan/pengaturan_screen.dart';
import 'statistik/statistik_screen.dart';
import '../shared/providers/settings_provider.dart';
import '../features/onboarding/ai_notice_sheet.dart';
import '../shared/theme/app_theme.dart';

/// MainShell — BottomNav 5 slot: Beranda · Jadwal · [FAB Tanya AI] ·
/// Statistik · Setelan (DESIGN §5.6). Sheet AI = overlay, bukan route.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  void _go(int i) => setState(() => _index = i);

  Future<void> _askAI() async {
    if (!context.read<SettingsProvider>().aiNoticeSeen) {
      final ok = await showAiNoticeSheet(context);
      if (!ok) return;
    }
    // Sheet AI: capture (text/teks/foto) → review craft draft → acc.
    if (mounted) await showAiCaptureFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BerandaScreen(),
      const JadwalScreen(),
      const StatistikScreen(),
      const PengaturanScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        onPressed: _askAI,
        child: Semantics(
          identifier: 'fab_ask_ai',
          button: true,
          label: 'Tanya AI',
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 22,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _BottomNav(index: _index, onTap: _go),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                identifier: 'nav_beranda',
                button: true,
                child: _NavBtn(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  active: index == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Semantics(
                identifier: 'nav_jadwal',
                button: true,
                child: _NavBtn(
                  icon: Icons.calendar_today_outlined,
                  label: 'Jadwal',
                  active: index == 1,
                  onTap: () => onTap(1),
                ),
              ),
              const SizedBox(width: 64),
              Semantics(
                identifier: 'nav_statistik',
                button: true,
                child: _NavBtn(
                  icon: Icons.pie_chart_rounded,
                  label: 'Statistik',
                  active: index == 2,
                  onTap: () => onTap(2),
                ),
              ),
              Semantics(
                identifier: 'nav_setelan',
                button: true,
                child: _NavBtn(
                  icon: Icons.settings_outlined,
                  label: 'Setelan',
                  active: index == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: _MainShellState._labelStyle.copyWith(
                color: active ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
