/// Domain model & enum Smart Todo — kontrak dari SCHEMA.md §7.
/// Kelas di file ini murni Dart (tanpa Flutter/DB) supaya 100% testable.
library;

enum Priority { high, medium, low }

enum Category { akademik, personal, organisasi, lainnya }

enum TaskSource { manual, aiVoice, aiText, aiPhoto }

/// Tab filter Beranda (FR-5 PRD).
enum TaskTab { all, today, upcoming, done }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.notes,
    required this.isDone,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final DateTime? deadline;
  final Priority priority;
  final Category category;
  final String? notes;
  final bool isDone;
  final TaskSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Overdue DINHITUNG saat baca (SCHEMA.md §2) — deadline lewat & belum selesai.
  bool isOverdue(DateTime now) =>
      deadline != null && !isDone && deadline!.isBefore(now);

  /// Deadline dalam hari kalender lokal yang sama dengan [now].
  bool isToday(DateTime now) {
    final d = deadline;
    if (d == null) return false;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Task copyWith({bool? isDone, String? title}) => Task(
    id: id,
    title: title ?? this.title,
    deadline: deadline,
    priority: priority,
    category: category,
    notes: notes,
    isDone: isDone ?? this.isDone,
    source: source,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Draft hasil parsing AI SEBELUM di-acc user (SCHEMA.md §7 TaskDraft).
/// Field selain title boleh null — user yang melengkapi di form review.
class TaskDraft {
  const TaskDraft({
    required this.title,
    this.deadline,
    this.priority,
    this.category,
    this.notes,
  });

  final String title;
  final DateTime? deadline;
  final Priority? priority;
  final Category? category;
  final String? notes;
}
