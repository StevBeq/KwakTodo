import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:todo_list/core/db/app_db.dart';
import 'package:todo_list/core/notifications/reminder_scheduler.dart';
import 'package:todo_list/features/splash/launcher_splash_screen.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/shared/providers/notif_provider.dart';
import 'package:todo_list/shared/providers/settings_provider.dart';
import 'package:todo_list/shared/providers/task_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Full Flow: Onboarding -> Tambah Tugas -> Selesai -> Statistik', (
    WidgetTester tester,
  ) async {
    // 1. Setup in-memory / testing database
    final db = AppDb.open();
    final settings = SettingsProvider(db);
    await settings.load();

    final notifProvider = NotifProvider(db);
    final scheduler = ReminderScheduler();
    final taskProvider = TaskProvider(db, scheduler: scheduler);
    taskProvider.remCfg = settings.remCfg;

    // 2. Launch App
    await tester.pumpWidget(
      SmartTodoApp(
        db: db,
        settings: settings,
        taskProvider: taskProvider,
        notifProvider: notifProvider,
      ),
    );
    await tester.pumpAndSettle();

    // 2.5 Lewati splash screen
    if (find.byType(LauncherSplashScreen).evaluate().isNotEmpty) {
      await tester.tap(find.byType(LauncherSplashScreen));
      await tester.pumpAndSettle();
    }

    // 3. Jika di Onboarding screen, selesaikan via tombol Mulai Sekarang / Lewati
    final startBtn = find.bySemanticsLabel('Mulai sekarang');
    final skipBtn = find.bySemanticsLabel('Lewati onboarding');
    if (startBtn.evaluate().isNotEmpty) {
      await tester.tap(startBtn);
      await tester.pumpAndSettle();
    } else if (skipBtn.evaluate().isNotEmpty) {
      await tester.tap(skipBtn);
      await tester.pumpAndSettle();
    }

    // 4. Verifikasi Beranda terbuka
    expect(find.text('Kwak'), findsOneWidget);
    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // 5. Buka Form Tambah Tugas
    final addBtn = find.byTooltip('Tambah manual');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // 6. Isi Form
    expect(find.text('Tugas Baru'), findsOneWidget);
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Uji Otomatis E2E');
    await tester.pumpAndSettle();

    // Tap tombol Tambahkan
    final submitBtn = find.widgetWithText(FilledButton, 'Tambahkan');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // 7. Verifikasi tugas muncul di Beranda
    expect(find.text('Uji Otomatis E2E'), findsOneWidget);
    expect(find.text('1 tugas · 0 selesai'), findsOneWidget);

    // 8. Buka Detail Tugas
    final taskCard = find.text('Uji Otomatis E2E');
    await tester.tap(taskCard);
    await tester.pumpAndSettle();

    // 9. Tandai Selesai
    final doneBtn = find.widgetWithText(InkWell, 'Tandai Selesai');
    if (doneBtn.evaluate().isNotEmpty) {
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();
    }

    // 10. Navigasi tab filter: Cek tab Selesai
    final tabDone = find.text('Selesai').first;
    await tester.tap(tabDone, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Uji Otomatis E2E'), findsOneWidget);

    // 11. Beralih ke layar Jadwal via Bottom Navigation
    final navJadwal = find.text('Jadwal');
    await tester.tap(navJadwal);
    await tester.pumpAndSettle();
    expect(find.text('Kalender'), findsNothing); // Menampilkan header Jadwal
    expect(find.text('Jadwal'), findsWidgets);

    // 12. Beralih ke layar Statistik via Bottom Navigation
    final navStatistik = find.text('Statistik');
    await tester.tap(navStatistik);
    await tester.pumpAndSettle();
    expect(find.text('Progres Selesai'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    // 13. Beralih ke layar Setelan
    final navSetelan = find.text('Setelan');
    await tester.tap(navSetelan);
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('API Key Gemini'), findsOneWidget);

    await db.close();
  });
}
