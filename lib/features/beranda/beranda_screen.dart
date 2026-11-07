library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../shared/providers/notif_provider.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/summary_card.dart';
import '../../shared/widgets/task_card.dart';
import '../task_detail/task_detail_sheet.dart';
import '../task_form/task_form_sheet.dart';
import '../notifikasi/notifikasi_screen.dart';
import 'category_row.dart';
import 'category_tasks_screen.dart';

/// TabFilter HomeTabs pill aktif primary (DESIGN §5).
final _homeTabLabels = {
  TaskTab.all: 'Semua',
  TaskTab.today: 'Hari Ini',
  TaskTab.upcoming: 'Mendatang',
  TaskTab.done: 'Selesai',
};

final _homeTabTitles = {
  TaskTab.all: 'Belum ada tugas',
  TaskTab.today: 'Belum ada tugas hari ini 🎉',
  TaskTab.upcoming: 'Tidak ada tugas mendatang',
  TaskTab.done: 'Belum ada yang selesai',
};

/// Beranda — DESIGN.md §5 #2: header (logo, bel+badge), SummaryCard,
/// 4 kartu kategori, HomeTabs, list TaskCard. Tombol tambah cukup dari
/// kartu (Tulis Manual) & FAB AI — tidak ada tombol + dobel di header.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  TaskTab _tab = TaskTab.all;

  void _openForm({Task? initial}) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        // Scrollable agar keyboard tidak membuat RenderFlex overflow tipis.
        child: SingleChildScrollView(child: TaskFormSheet(initial: initial)),
      ),
    );
  }

  void _bell() {
    // Inbox notifikasi — fase F3 (sub-layar via Navigator, ARCH §3).
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageCtx) =>
            NotifikasiScreen(onBack: () => Navigator.pop(pageCtx)),
      ),
    );
  }

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryTasksScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final unread = context.watch<NotifProvider>().hasUnread;

    final now = DateTime.now();
    final list = provider.forTab(_tab, now);
    final doneCount = provider.tasks.where((t) => t.isDone).length;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onNotif: _bell, hasUnread: unread),
            const SizedBox(height: 12),
            SummaryCard(
              total: provider.tasks.length,
              done: doneCount,
              onManual: () => _openForm(),
            ),
            const SizedBox(height: 16),
            CategoryRow(tasks: provider.tasks, onCategoryTap: _openCategory),
            const SizedBox(height: 24),
            _HomeTabs(active: _tab, onPick: (t) => setState(() => _tab = t)),
            const SizedBox(height: 12),
            if (list.isEmpty)
              EmptyState(
                title: _homeTabTitles[_tab]!,
                subtitle:
                    'Pakai "Manual" untuk input sendiri, atau "Tanya '
                    'AI" biar cepat.',
              )
            else
              ...List.generate(
                list.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    task: list[i],
                    now: now,
                    onTap: () => showTaskDetailSheet(context, list[i], now),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNotif, required this.hasUnread});

  final VoidCallback onNotif;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    const circle = BoxDecoration(
      color: AppColors.surface,
      shape: BoxShape.circle,
    );
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryShadow.withValues(alpha: .3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primary,
                alignment: Alignment.center,
                child: const Text('🦆', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kwak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'Todo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Semantics(
          identifier: 'header_notif_btn',
          button: true,
          label: 'Notifikasi',
          child: Tooltip(
            message: 'Notifikasi',
            child: InkWell(
              onTap: onNotif,
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: circle.copyWith(),
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: -1,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
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

// SPLIT: _CategoryRow/_CategoryCard dipindah ke category_row.dart (batas 300 baris).
class _HomeTabs extends StatelessWidget {
  const _HomeTabs({required this.active, required this.onPick});

  final TaskTab active;
  final ValueChanged<TaskTab> onPick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final tab in TaskTab.values) ...[
            if (tab != TaskTab.values.first) const SizedBox(width: 8),
            Semantics(
              identifier: 'tab_${tab.name}',
              button: true,
              child: InkWell(
                onTap: () => onPick(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: tab == active
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    _homeTabLabels[tab]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tab == active
                          ? AppColors.surface
                          : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
