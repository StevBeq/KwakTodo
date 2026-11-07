import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/core/db/app_db.dart';
import 'package:todo_list/core/notifications/reminder_scheduler.dart';
import 'package:todo_list/features/splash/launcher_splash_screen.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/shared/providers/notif_provider.dart';
import 'package:todo_list/shared/providers/settings_provider.dart';
import 'package:todo_list/shared/providers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  testWidgets(
    'E2E Widget Test: Onboarding -> Tambah Tugas -> Selesai -> Statistik',
    (WidgetTester tester) async {
      final db = AppDb.memory();
      final settings = SettingsProvider(db);
      await settings.load();

      final notifProvider = NotifProvider(db);
      final scheduler = ReminderScheduler();
      final taskProvider = TaskProvider(db, scheduler: scheduler);
      taskProvider.remCfg = settings.remCfg;

      await tester.pumpWidget(
        SmartTodoApp(
          db: db,
          settings: settings,
          taskProvider: taskProvider,
          notifProvider: notifProvider,
        ),
      );
      await tester.pumpAndSettle();

      // 0. Lewati animasi splash screen
      if (find.byType(LauncherSplashScreen).evaluate().isNotEmpty) {
        await tester.tap(find.byType(LauncherSplashScreen));
        await tester.pumpAndSettle();
      }

      // 1. Lewati atau Mulai dari Onboarding
      final startBtn = find.text('Mulai Sekarang');
      final skipBtn = find.text('Lewati');
      if (startBtn.evaluate().isNotEmpty) {
        await tester.tap(startBtn);
        await tester.pumpAndSettle();
      } else if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn);
        await tester.pumpAndSettle();
      }

      // 2. Beranda aktif
      expect(find.text('Kwak'), findsOneWidget);
      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('Belum ada tugas'), findsOneWidget);

      // 3. Tambah tugas manual (kartu Beranda, bukan tombol header lama)
      final addBtn = find.text('Tulis Manual');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // 4. Input judul tugas
      expect(find.text('Tugas Baru'), findsOneWidget);
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Uji Otomatis E2E');
      await tester.pumpAndSettle();

      // 5. Submit
      final submitBtn = find.widgetWithText(FilledButton, 'Tambahkan');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // 6. Tugas muncul di list
      expect(find.text('Uji Otomatis E2E'), findsOneWidget);
      expect(find.text('1 tugas · 0 selesai'), findsOneWidget);

      // 7. Buka detail tugas
      final taskCard = find.text('Uji Otomatis E2E');
      await tester.tap(taskCard);
      await tester.pumpAndSettle();

      // 8. Tandai selesai
      final doneBtn = find.text('Tandai Selesai');
      expect(doneBtn, findsOneWidget);
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      // 9. Cek tab Selesai
      final tabDone = find.text('Selesai').first;
      await tester.tap(tabDone, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Uji Otomatis E2E'), findsOneWidget);

      // 10. Navigasi ke Jadwal
      final navJadwal = find.text('Jadwal');
      await tester.tap(navJadwal);
      await tester.pumpAndSettle();
      expect(find.text('Jadwal'), findsWidgets);

      // 11. Navigasi ke Statistik
      final navStatistik = find.text('Statistik');
      await tester.tap(navStatistik);
      await tester.pumpAndSettle();
      expect(find.text('Progres Selesai'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // 12. Navigasi ke Setelan
      final navSetelan = find.text('Setelan');
      await tester.tap(navSetelan);
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('API Key Gemini'), findsOneWidget);

      await db.close();
    },
  );
}
