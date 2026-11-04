/// Smart Todo — bootstrap (ARCHITECTURE.md §7): DB → notif → providers → runApp.
library;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/db/app_db.dart';
import 'core/notifications/notifier.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'features/splash/launcher_splash_screen.dart';
import 'shared/providers/notif_provider.dart';
import 'shared/providers/settings_provider.dart';
import 'shared/providers/task_provider.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb.open();
  final settings = SettingsProvider(db);
  await settings.load();
  final notifProvider = NotifProvider(db);
  final scheduler = ReminderScheduler();
  final taskProvider = TaskProvider(db, scheduler: scheduler);
  taskProvider.remCfg = settings.remCfg;

  // ARCHITECTURE §6–7: init plugin + izin; notif diketuk → tulis inbox.
  await Notifier.init(
    onTap: (NotificationResponse r) async {
      final p = r.payload;
      if (p != null && p.isNotEmpty) {
        await _logReminder(notifProvider, p);
      }
    },
  );

  // App dibuka dari notifikasi (cold start) → catat juga di inbox.
  final launch = await Notifier.launchNotification();
  final launchPayload = launch?.notificationResponse?.payload;
  if (launch?.didNotificationLaunchApp ?? false) {
    if (launchPayload != null && launchPayload.isNotEmpty) {
      await _logReminder(notifProvider, launchPayload);
    }
  }

  // Rekonstruksi semua jadwal (tahan reboot & perubahan jam device).
  await scheduler.rescheduleAll(await db.taskDao.getAll(), settings.remCfg);

  settings.onReminderChanged = () async {
    taskProvider.remCfg = settings.remCfg;
    await taskProvider.rescheduleAll(settings.remCfg);
  };

  runApp(
    SmartTodoApp(
      db: db,
      settings: settings,
      taskProvider: taskProvider,
      notifProvider: notifProvider,
    ),
  );
}

/// Tulis baris inbox dari notifikasi reminder yang diketuk.
Future<void> _logReminder(NotifProvider n, String payload) =>
    n.add(title: '⏰ Pengingat: $payload', body: 'Dari notifikasi reminder.');

class SmartTodoApp extends StatelessWidget {
  const SmartTodoApp({
    super.key,
    required this.db,
    required this.settings,
    required this.taskProvider,
    required this.notifProvider,
  });

  final AppDb db;
  final SettingsProvider settings;
  final TaskProvider taskProvider;
  final NotifProvider notifProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ChangeNotifierProvider<NotifProvider>.value(value: notifProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ],
      child: MaterialApp(
        title: 'KwakTodo',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LauncherSplashScreen(),
      ),
    );
  }
}
