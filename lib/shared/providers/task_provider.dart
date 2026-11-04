import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/db/app_db.dart';
import '../../core/notifications/reminder_scheduler.dart';
import '../../core/utils/filters.dart';
import '../../core/domain/models.dart';

/// State UI list tugas — ARCHITECTURE.md §4.1 (bukan AsyncValue riverpod;
/// sealed state manual karena stack memakai provider).
sealed class TaskListState {
  const TaskListState();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListLoaded extends TaskListState {
  const TaskListLoaded(this.tasks);
  final List<Task> tasks;
}

class TaskListError extends TaskListState {
  const TaskListError(this.message);
  final String message;
}

/// Sumber kebenaran = DB (stream). Provider hanya membungkus — ARCHITECTURE §4.2.
class TaskProvider extends ChangeNotifier {
  TaskProvider(this._db, {ReminderScheduler? scheduler})
    : _scheduler = scheduler {
    _db.taskDao.watchAll().listen(
      (list) {
        _tasks = list;
        _state = TaskListLoaded(list);
        notifyListeners();
      },
      onError: (Object e) {
        _state = TaskListError('Gagal memuat tugas. Coba lagi.');
        notifyListeners();
      },
    );
  }

  final AppDb _db;
  final ReminderScheduler? _scheduler;

  // Konfigurasi reminder aktif — di-set dari main saat settings berubah
  // (RULES §4.4: scheduler selalu pakai konfigurasi terbaru).
  RemCfg? _remCfg;
  set remCfg(RemCfg? v) => _remCfg = v;
  List<Task> _tasks = const [];
  TaskListState _state = const TaskListLoading();

  // ===== Delete + UNDO window 4 detik (ARCHITECTURE §4.2) =====
  // Task hilang dari UI seketika; baris DB baru dihapus setelah jendela lewat.
  // UNDO membatalkan timer — id tidak berubah, posisi list tetap.
  final Set<int> _pendingDelete = {};
  final Map<int, Timer> _deleteTimers = {};
  final Map<int, Task> _deleteSnapshot = {};

  bool isPendingDelete(int id) => _pendingDelete.contains(id);

  TaskListState get state => _state;

  /// Task terlihat UI = tanpa yang sedang menunggu UNDO (ARCHITECTURE §4.2).
  List<Task> get tasks =>
      _tasks.where((t) => !_pendingDelete.contains(t.id)).toList();

  /// Re-notify setelah perubahan _pendingDelete (list & state tetap sinkron).
  void _emit() {
    _state = TaskListLoaded(tasks);
    notifyListeners();
  }

  /// Mulai jendela UNDO 4 detik; commit hapus bila tidak dibatalkan.
  void startDelete(Task task) {
    if (_pendingDelete.contains(task.id)) return;
    _deleteSnapshot[task.id] = task;
    _pendingDelete.add(task.id);
    _emit();
    _deleteTimers[task.id]?.cancel();
    _deleteTimers[task.id] = Timer(const Duration(seconds: 4), () async {
      _deleteTimers.remove(task.id);
      try {
        await _db.taskDao.deleteTask(task.id);
        // SCHEMA §8: tugas dihapus → notifikasi dibatalkan.
        await _scheduler?.cancelTask(task);
      } finally {
        _pendingDelete.remove(task.id);
        _deleteSnapshot.remove(task.id);
        _emit();
      }
    });
  }

  /// UNDO ditekan — batalkan penghapusan, task muncul kembali di place asal
  /// (id tidak berubah); reminder ikut dipasang ulang (RULES §4.4).
  void cancelDelete(int id) {
    _deleteTimers[id]?.cancel();
    _deleteTimers.remove(id);
    if (_pendingDelete.remove(id)) {
      _deleteSnapshot.remove(id);
      _emit();
      _scheduleChanged(id);
    }
  }

  /// Query tab beranda — murni setelah stream memberi data (F2+).
  /// Sumber = task terlihat (tanpa yang menunggu UNDO) supaya kartu
  /// langsung menghilang saat startDelete.
  List<Task> forTab(TaskTab tab, DateTime now) =>
      TaskFilters.forTab(tasks, tab, now);

  /// Insert + trigger stream dari DB → UI otomatis update (RULES §5.7).
  /// Reminder pasang untuk tugas ber-deadline yang belum lewat.
  Future<int> add({
    required String title,
    DateTime? deadline,
    Priority priority = Priority.medium,
    Category category = Category.akademik,
    String? notes,
    TaskSource source = TaskSource.manual,
  }) async {
    final id = await _db.taskDao.insertTask(
      title: title,
      deadline: deadline,
      priority: priority,
      category: category,
      notes: notes,
      source: source,
    );
    await _scheduleChanged(id);
    return id;
  }

  /// Task aktif (non-pending) → reschedule sesuai konfigurasi sekarang.
  /// computeSchedule berani return null (deadline kosong/selesai/minus) —
  /// scheduler cancel dulu jadi tidak ada alarm basi.
  Future<void> _scheduleChanged(int id) async {
    final s = _scheduler;
    final cfg = _remCfg;
    if (s == null || cfg == null) return;
    final t = await _db.taskDao.get(id);
    if (t != null) await s.schedule(t, cfg);
  }

  /// Pasang/perbarui SEMUA jadwal (startup + perubahan cfg Reminder).
  Future<void> rescheduleAll(RemCfg cfg) async {
    final s = _scheduler;
    if (s == null) return;
    await s.rescheduleAll(_tasks, cfg);
  }

  Future<void> toggleDone(Task t) async {
    await _db.taskDao.updateFields(t.id, isDone: !t.isDone);
    await _scheduleChanged(t.id);
  }

  Future<void> edit(
    Task t, {
    String? title,
    DateTime? deadline,
    Priority? priority,
    Category? category,
    String? notes,
  }) async {
    await _db.taskDao.updateFields(
      t.id,
      title: title,
      deadline: deadline,
      priority: priority,
      category: category,
      notes: notes,
    );
    // RULES §4.4: edit task ber-deadline → selalu reschedule; deadline
    // dihapus → computeSchedule null → hanya cancel (SCHEMA §8).
    await _scheduleChanged(t.id);
  }
}
