library;

import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/db/app_db.dart';

/// Notifikasi — badge bel + inbox lokal (DESIGN §5, SCHEMA §3):
/// badge = stream unread count; layar Inbox ikat [items] dan pakai CRUD DAO
/// (tandai baca satu/semua, hapus, retensi 100 baris otomatis saat tambah).
class NotifProvider extends ChangeNotifier {
  NotifProvider(this._db) {
    _sub = _db.notificationDao.watchUnreadCount().listen((n) {
      _unread = n;
      notifyListeners();
    }, onError: (Object _) => _unread = 0);
  }

  final AppDb _db;
  late final StreamSubscription<int> _sub;
  int _unread = 0;

  bool get hasUnread => _unread > 0;
  int get unreadCount => _unread;

  Stream<List<Notification>> get items => _db.notificationDao.watchAll();

  /// Tambah item (dipakai modul reminder F5 & notifikasi tes) + retensi.
  Future<void> add({
    required String title,
    required String body,
    int? taskId,
  }) async {
    await _db.notificationDao.add(title: title, body: body, taskId: taskId);
    await _db.notificationDao.enforceRetention();
  }

  Future<void> markRead(int id) => _db.notificationDao.markRead(id);

  Future<void> markAllRead() => _db.notificationDao.markAllRead();

  Future<void> deleteItem(int id) => _db.notificationDao.deleteItem(id);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
