import 'package:drift/drift.dart';

import '../domain/models.dart';

/// Schema v1 — SCHEMA.md §2/§3/§4. Kolom = kontrak, jangan diubah tanpa revisi.

// ——— tabel tasks ———
// DataClassName disengaja `TaskRow` supaya TIDAK bentrok dengan domain
// model `Task` (lib/core/domain/models.dart) — ARCHITECTURE.md §2.
@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get deadline => dateTime().nullable()();

  TextColumn get priority =>
      textEnum<Priority>().withDefault(const Constant('medium'))();
  TextColumn get category => textEnum<Category>()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get source =>
      textEnum<TaskSource>().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// ——— tabel notifications (inbox lokal) ———
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  IntColumn get taskId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

// ——— tabel app_settings (key-value non-secret) ———
class AppSettings extends Table {
  TextColumn get keyK => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {keyK};
}
