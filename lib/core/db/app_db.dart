import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'daos.dart';
import 'tables.dart';

// Import eksplisit untuk part file (drift_dev tidak menyuntikkan import enum
// saat table di file terpisah — quirk analyzer version skew).
import '../domain/models.dart';

part 'app_db.g.dart';

/// AppDb — drift database v1 (SCHEMA.md §9).
/// schemaVersion naik + migrasi eksplisit ditulis di sini setiap skema berubah.
@DriftDatabase(
  tables: [Tasks, Notifications, AppSettings],
  daos: [TaskDao, NotificationDao, SettingsDao],
)
class AppDb extends _$AppDb {
  AppDb.open() : super(_open());
  AppDb.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Versi 1 = schema pertama. Saat deploy berikutnya menambah kolom
      // atau tabel: naikkan schemaVersion dan tulis migrasi eksplisit
      // di sini (SCHEMA.md §9) — bukan edit-table lupa migrasi.
    },
  );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/smarttodo.sqlite');
    // createInBackground = query jalan di isolate kecil, UI tetap mulus
    // (ARCHITECTURE §8 — performa list tanpa jank).
    return NativeDatabase.createInBackground(file);
  });
}

// ============ tabel berikut direferensikan drift lewat tables.dart ============
// Tasks, Notifications, AppSettings — lihat tables.dart (schema v1).
