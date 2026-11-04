import '../domain/models.dart';

/// Dua DateTime dalam hari kalender lokal yang sama (helper murni).
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Filter & sort murni untuk tab Beranda (FR-5) — fungsi murni supaya testable.
class TaskFilters {
  const TaskFilters._();

  /// List untuk tab [tab] sesuai definisi SCHEMA.md §6 / PRD FR-5:
  /// - all      : semua task
  /// - today    : deadline hari ini ATAU overdue (belum selesai)
  /// - upcoming : deadline masa depan, belum selesai
  /// - done     : semua yang selesai
  static List<Task> forTab(List<Task> tasks, TaskTab tab, DateTime now) {
    switch (tab) {
      case TaskTab.all:
        return sortByDeadline(tasks);
      case TaskTab.today:
        return sortByDeadline(
          tasks
              .where((t) => !t.isDone && (t.isToday(now) || t.isOverdue(now)))
              .toList(),
        );
      case TaskTab.upcoming:
        return sortByDeadline(
          tasks
              .where(
                (t) =>
                    !t.isDone &&
                    t.deadline != null &&
                    !t.isToday(now) &&
                    !t.isOverdue(now),
              )
              .toList(),
        );
      case TaskTab.done:
        return sortByDeadline(tasks.where((t) => t.isDone).toList());
    }
  }

  /// Deadline terdekat dulu; yang tanpa deadline di paling bawah.
  static List<Task> sortByDeadline(List<Task> tasks) {
    final list = [...tasks];
    list.sort((a, b) {
      final da = a.deadline, db = b.deadline;
      if (da == null && db == null) return b.updatedAt.compareTo(a.updatedAt);
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return list;
  }
}

/// Label statis kategori — token warna ada di AppColors (shared/theme).
const categoryLabels = {
  Category.akademik: 'Akademik',
  Category.personal: 'Personal',
  Category.organisasi: 'Organisasi',
  Category.lainnya: 'Lainnya',
};

const priorityLabels = {
  Priority.high: 'Tinggi',
  Priority.medium: 'Sedang',
  Priority.low: 'Santai',
};

final tabLabels = {
  TaskTab.all: 'Semua',
  TaskTab.today: 'Hari Ini',
  TaskTab.upcoming: 'Mendatang',
  TaskTab.done: 'Selesai',
};
