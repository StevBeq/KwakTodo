/// Notifier — init plugin, izin, tampilkan notif (ARCHITECTURE.md §6).
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wrapper tipis di atas flutter_local_notifications: satu pintu untuk
/// init + izin + tampil sekarang + jadwal zona waktu + cancel.
/// Menerima callback dipanggil saat notifikasi diketuk/dibuka dari setup.
class Notifier {
  Notifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static bool _ready = false;

  /// Init timezone data (zona waktu device lokal) + plugin + izin.
  /// Android 13+: izin POST_NOTIFICATIONS diminta runtime.
  static Future<void> init({
    required DidReceiveNotificationResponseCallback onTap,
  }) async {
    tzdata.initializeTimeZones();
    final localName = _deviceTimeZone();
    try {
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onTap,
    );

    // izin tampilan notif (Android 13+)
    final and = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await and?.requestNotificationsPermission();

    _ready = true;
  }

  /// Detail launch (tahan cold-start lewat tap notifikasi) — main.dart.
  static Future<NotificationAppLaunchDetails?> launchNotification() async {
    final and = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await and?.getNotificationAppLaunchDetails();
  }

  /// Nama zona waktu device (Android: WIB/WITA/WIT; fallback Jakarta).
  static String _deviceTimeZone() {
    final name = DateTime.now().timeZoneName;
    if (name.contains('WITA')) return 'Asia/Makassar';
    if (name.contains('WIT')) return 'Asia/Jayapura';
    return 'Asia/Jakarta';
  }

  static bool get isReady => _ready;

  /// Lidah notifikasi Android 14 exact alarm; kalau ditolak, jadwal
  /// zonedSchedule tetap jadi alarm inexact (fallback ARCHITECTURE §6).
  static Future<bool> requestExactAlarm() async {
    final and = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await and?.requestExactAlarmsPermission() ?? false;
  }

  /// Minta izin tampil notifikasi saat user menekan baris izin di
  /// Pengaturan; kalau ditolak → arahkan ke Settings HP.
  static Future<bool> requestDisplayPermission() async {
    final and = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await and?.requestNotificationsPermission() ?? false;
    if (granted) return true;
    await and?.openAppNotificationSettings();
    return false;
  }

  /// Tampil sekarang (tombol tes Pengaturan). id unik bebas, pasang id
  /// sama dengan taskId supaya cancel(id) konsisten.
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }

  /// Jadwalkan alarm pada [at] dengan payload = isi di-[write] inbox saat
  /// diketuk. id unik per tugas (id task dipakai langsung).
  static Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
  }) async {
    if (!_ready) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminder',
      'Reminder deadline',
      channelDescription: 'Pengingat deadline tugas H-N',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Batalkan jadwal id ini (deadline dihapus / tugas dihapus / selesai).
  static Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id: id);
  }
}
