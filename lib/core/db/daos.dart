import 'package:drift/drift.dart';

import '../domain/models.dart';
import 'app_db.dart';
import 'tables.dart';

part 'daos.g.dart';

/// DAO tasks — query inti dari SCHEMA.md §6.
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDb> with _$TaskDaoMixin {
  TaskDao(super.db);

  Task _rowToTask(TaskRow row) => Task(
    id: row.id,
    title: row.title,
    deadline: row.deadline,
    priority: row.priority,
    category: row.category,
    notes: row.notes,
    isDone: row.isDone,
    source: row.source,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  Stream<List<Task>> watchAll() =>
      select(tasks).watch().map((rows) => rows.map(_rowToTask).toList());

  /// Ambil satu task (untuk reschedule setelah mutasi — RULES §4.4).
  Future<Task?> get(int id) async {
    final row = await (select(
      tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToTask(row);
  }

  Future<List<Task>> getAll() =>
      select(tasks).get().then((rows) => rows.map(_rowToTask).toList());

  /// Insert dengan double gate (RULES §5.1): title 1..100 char, notes ≤500.
  Future<int> insertTask({
    required String title,
    DateTime? deadline,
    Priority priority = Priority.medium,
    Category category = Category.akademik,
    String? notes,
    TaskSource source = TaskSource.manual,
  }) async {
    final t = title.trim();
    if (t.isEmpty) {
      throw ArgumentError('title tidak boleh kosong (RULES §5.1)');
    }
    if (t.length > 100) {
      throw ArgumentError('title maksimal 100 char (SCHEMA §2)');
    }
    final n = notes?.trim();
    if (n != null && n.length > 500) {
      throw ArgumentError('notes maksimal 500 char (SCHEMA §2)');
    }
    final now = DateTime.now();
    return into(tasks).insert(
      TasksCompanion.insert(
        title: t,
        deadline: Value(deadline),
        priority: Value(priority),
        category: category,
        notes: Value(n),
        source: Value(source),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateFields(
    int id, {
    String? title,
    DateTime? deadline,
    Priority? priority,
    Category? category,
    String? notes,
    bool? isDone,
  }) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: title == null ? const Value.absent() : Value(title.trim()),
        deadline: deadline == null ? const Value.absent() : Value(deadline),
        priority: priority == null ? const Value.absent() : Value(priority),
        category: category == null ? const Value.absent() : Value(category),
        notes: notes == null ? const Value.absent() : Value(notes),
        isDone: isDone == null ? const Value.absent() : Value(isDone),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete true (dipakai setelah undo-window 4 detik — ARCHITECTURE §4.2).
  Future<void> deleteTask(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();
}

/// DAO notifications — inbox lokal (SCHEMA.md §3).
@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDb>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  Stream<List<Notification>> watchAll() => (select(
    notifications,
  )..orderBy([(n) => OrderingTerm.desc(n.createdAt)])).watch();

  Stream<int> watchUnreadCount() {
    final countExp = notifications.read.count();
    final q = selectOnly(notifications)
      ..addColumns([countExp])
      ..where(notifications.read.equals(false));
    return q.watchSingle().map((r) => r.read(countExp) ?? 0);
  }

  Future<void> add({required String title, required String body, int? taskId}) {
    return into(notifications).insert(
      NotificationsCompanion.insert(
        title: title,
        body: body,
        taskId: Value(taskId),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> markRead(int id) =>
      (update(notifications)..where((n) => n.id.equals(id))).write(
        const NotificationsCompanion(read: Value(true)),
      );

  Future<void> markAllRead() {
    return (update(notifications)..where((n) => n.read.equals(false))).write(
      const NotificationsCompanion(read: Value(true)),
    );
  }

  Future<void> deleteItem(int id) =>
      (delete(notifications)..where((n) => n.id.equals(id))).go();

  /// Retensi (SCHEMA.md §3): max 100 baris — hapus read paling tua.
  Future<void> enforceRetention() async {
    final expired =
        await (select(notifications)
              ..orderBy([(n) => OrderingTerm.asc(n.createdAt)])
              ..limit(1000))
            .get();
    if (expired.length <= 100) return;
    final toDelete = expired
        .where((n) => n.read)
        .take(expired.length - 100)
        .toList();
    for (final n in toDelete) {
      await (delete(notifications)..where((x) => x.id.equals(n.id))).go();
    }
  }
}

/// DAO app_settings — key-value non-secret (SCHEMA.md §4).
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDb> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getRaw(String key) async {
    final q = select(appSettings)..where((s) => s.keyK.equals(key));
    final row = await q.getSingleOrNull();
    return row?.value;
  }

  Future<void> setRaw(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(keyK: key, value: value),
    );
  }

  // helper bertipe — RULES: selalu lewat helper ini, tidak cast raw di UI.
  Future<bool> getBool(String key, {bool orDefault = false}) async {
    final raw = await getRaw(key);
    return raw == null ? orDefault : raw == '1';
  }

  Future<int> getInt(String key, {required int orDefault}) async {
    final raw = await getRaw(key);
    if (raw == null) return orDefault;
    return int.tryParse(raw) ?? orDefault;
  }

  Future<void> setBool(String key, bool v) => setRaw(key, v ? '1' : '0');
  Future<void> setInt(String key, int v) => setRaw(key, '$v');
}
