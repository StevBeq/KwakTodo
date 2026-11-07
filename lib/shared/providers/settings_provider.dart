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
  List<RemRule> _remRules = const [RemRule(unit: RemUnit.day, n: 2)];

  /// Diregistrasi main.dart: dipanggil tiap konfigurasi reminder berubah
  /// agar semua jadwal dipasang ulang (RULES §4.4).
  void Function()? onReminderChanged;

  // API key — hanya in-memory, sumber kebenaran keystore.
  List<String> _apiKeys = [];

  bool get isLoaded => _loaded;
  bool get onboarded => _onboarded ?? false;
  bool get aiNoticeSeen => _aiNoticeSeen ?? false;

  bool get remEnabled => _remEnabled;
  List<RemRule> get remRules => List.unmodifiable(_remRules);

  /// Batas aturan di UI (scheduler punya slot cadangan lebih besar).
  static const maxRules = 8;

  /// Opsi pemilih jam (aturan mode hari) — dari prototype select remHour.
  static const remHourOptions = [4, 6, 8, 10, 12, 20, 21, 22];

  /// Halaman reminder dianggap sederhana bila isinya satu aturan.
  /// Nama aturan gabungan utk baris ringkas di halaman Pengaturan.
  String get remRulesLabel => _remRules.isEmpty
      ? 'Belum ada aturan'
      : _remRules.map((r) => r.label).join('  ·  ');

  List<String> get apiKeys => List.unmodifiable(_apiKeys);

  /// Konfigurasi reminder saat ini (dipakai scheduler — RULES §4.4).
  RemCfg get remCfg => RemCfg(enabled: _remEnabled, rules: _remRules);

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
    _remRules = await _loadRules();
    await loadApiKeys();
    _loaded = true;
    notifyListeners();
  }

  /// Muat aturan dari app_settings (JSON list of RemRule); kosong →
  /// migrasi satu-atrur dari setting lama rem_days/rem_hour (v1).
  Future<List<RemRule>> _loadRules() async {
    final raw = await _db.settingsDao.getRaw('rem_rules');
    if (raw != null) {
      try {
        final decoded = (jsonDecode(raw) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(RemRule.fromJson)
            .toList();
        if (decoded.isNotEmpty) return decoded;
      } on FormatException {
        // raw rusak → jatuh ke migrasi data lama di bawah.
      }
    }
    final legacyDays = await _db.settingsDao.getInt('rem_days', orDefault: 2);
    final legacyHour = await _db.settingsDao.getInt('rem_hour', orDefault: 8);
    return [RemRule(unit: RemUnit.day, n: legacyDays, hour: legacyHour)];
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

  /// Toggle reminder utama.
  Future<void> setReminderEnabled(bool enabled) async {
    _remEnabled = enabled;
    notifyListeners();
    await _db.settingsDao.setBool('rem_enabled', enabled);
    onReminderChanged?.call();
  }

  /// Tambah aturan reminder (H-N hari@jam / H-N jam) + reschedule.
  Future<void> addRemRule(RemRule rule) async {
    if (_remRules.length >= maxRules) return;
    _remRules = [..._remRules, rule];
    notifyListeners();
    await _persistRules();
    onReminderChanged?.call();
  }

  /// Hapus aturan indeks [i] + reschedule (slot ikut di-cancel).
  Future<void> removeRemRule(int index) async {
    _remRules = [..._remRules]..removeAt(index);
    notifyListeners();
    await _persistRules();
    onReminderChanged?.call();
  }

  Future<void> _persistRules() => _db.settingsDao.setRaw(
    'rem_rules',
    jsonEncode([for (final r in _remRules) r.toJson()]),
  );

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
