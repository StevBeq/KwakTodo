library;

import 'dart:async';
import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/db/app_db.dart';
import '../../core/notifications/reminder_scheduler.dart';

/// Wrapper setting — app_settings key-value non-secret + keystore untuk
/// API key (SCHEMA §4, MASTER_SPEC §6). RULES: UI tidak cast raw string,
/// selalu lewat helper bertipe di sini.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._db);

  final AppDb _db;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keysKeystore = 'gemini_api_keys';

  bool? _onboarded;
  bool? _aiNoticeSeen;
  bool _loaded = false;

  // reminder (penyimpanan DB; penjadwalan aktual = fase F5)
  bool _remEnabled = false;
  int _remDays = 2; // H-N
  int _remHour = 8; // pukul NN:00

  /// Diregistrasi main.dart: dipanggil tiap konfigurasi reminder berubah
  /// agar semua jadwal dipasang ulang (RULES §4.4).
  void Function()? onReminderChanged;

  // API key — hanya in-memory, sumber kebenaran keystore.
  List<String> _apiKeys = [];

  bool get isLoaded => _loaded;
  bool get onboarded => _onboarded ?? false;
  bool get aiNoticeSeen => _aiNoticeSeen ?? false;

  bool get remEnabled => _remEnabled;
  int get remDays => _remDays;
  int get remHour => _remHour;

  // opsi dropdown reminder (prototype select remDays/remHour)
  static const remDaysOptions = [1, 2, 3, 7];
  static const remHourOptions = [4, 6, 8, 10, 12, 20, 21, 22];

  List<String> get apiKeys => List.unmodifiable(_apiKeys);

  /// Konfigurasi reminder saat ini (dipakai scheduler — RULES §4.4).
  RemCfg get remCfg =>
      RemCfg(enabled: _remEnabled, leadDays: _remDays, hour: _remHour);

  /// API key pertama non-kosong (dipakai modul AI fase F4).
  String get activeApiKey {
    for (final k in _apiKeys) {
      if (k.trim().isNotEmpty) return k.trim();
    }
    return '';
  }

  Future<void> load() async {
    _onboarded = await _db.settingsDao.getBool('onboarded');
    _aiNoticeSeen = await _db.settingsDao.getBool('ai_notice_seen');
    _remEnabled = await _db.settingsDao.getBool('rem_enabled');
    _remDays = await _db.settingsDao.getInt('rem_days', orDefault: 2);
    _remHour = await _db.settingsDao.getInt('rem_hour', orDefault: 8);
    await loadApiKeys();
    _loaded = true;
    notifyListeners();
  }

  Future<void> markOnboarded() async {
    _onboarded = true;
    notifyListeners();
    await _db.settingsDao.setBool('onboarded', true);
  }

  Future<void> markAiNoticeSeen() async {
    _aiNoticeSeen = true;
    notifyListeners();
    await _db.settingsDao.setBool('ai_notice_seen', true);
  }

  /// Simpan konfigurasi reminder (toggle + H-N + jam sekaligus).
  Future<void> setReminder({
    required bool enabled,
    required int days,
    required int hour,
  }) async {
    _remEnabled = enabled;
    _remDays = days;
    _remHour = hour;
    notifyListeners();
    await _db.settingsDao.setBool('rem_enabled', enabled);
    await _db.settingsDao.setInt('rem_days', days);
    await _db.settingsDao.setInt('rem_hour', hour);
    onReminderChanged?.call();
  }

  /// Muat API key dari keystore (jsonEncode array — MASTER_SPEC §6).
  Future<void> loadApiKeys() async {
    final raw = await _storage.read(key: _keysKeystore);
    try {
      final decoded = raw == null ? null : jsonDecode(raw) as List<dynamic>;
      _apiKeys = decoded?.cast<String>() ?? <String>[];
    } on FormatException {
      _apiKeys = <String>[];
    }
    if (_apiKeys.isEmpty) _apiKeys = List.filled(1, '');
    notifyListeners();
  }

  Future<void> saveApiKeys(List<String> keys) async {
    _apiKeys = keys.map((k) => k.trim()).toList();
    notifyListeners();
    await _storage.write(
      key: _keysKeystore,
      value: jsonEncode(_apiKeys.where((k) => k.isNotEmpty).toList()),
    );
  }
}
