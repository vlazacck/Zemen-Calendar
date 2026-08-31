/// ─────────────────────────────────────────────────────────────────────────────
///  ZEMEN HIVE STORE
///  Fast key-value storage for app state that needs to persist across sessions
///  but doesn't require relational queries: language, theme, settings,
///  cached calendar calculations (Bahire Hasab results, etc.)
///
///  Hive boxes:
///   - "settings"   : AppSettings (language, theme, toggles)
///   - "cache"      : Cached calculation results (movable feasts per year, etc.)
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class ZemenHiveStore {
  ZemenHiveStore._internal();
  static final ZemenHiveStore instance = ZemenHiveStore._internal();

  static const String settingsBoxName = 'zemen_settings';
  static const String cacheBoxName = 'zemen_cache';

  late Box _settingsBox;
  late Box _cacheBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(settingsBoxName);
    _cacheBox = await Hive.openBox(cacheBoxName);
    _initialized = true;
  }

  // ── Settings Keys ──────────────────────────────────────────────────────

  static const String keyLanguage = 'language'; // 'am' | 'en'
  static const String keyThemeMode = 'theme_mode'; // 'dark' | 'light' | 'system'
  static const String keyShowGregorian = 'show_gregorian';
  static const String keyShowMoonPhase = 'show_moon_phase';
  static const String keyShowEthiopianTime = 'show_ethiopian_time';
  static const String keyEnableFeastReminders = 'enable_feast_reminders';
  static const String keyEnableFastingReminders = 'enable_fasting_reminders';
  static const String keyEnableDailySaint = 'enable_daily_saint';
  static const String keyReminderAdvanceDays = 'reminder_advance_days';
  static const String keyOnboardingComplete = 'onboarding_complete';

  // ── Generic Settings API ──────────────────────────────────────────────

  T getSetting<T>(String key, T defaultValue) {
    return (_settingsBox.get(key) as T?) ?? defaultValue;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> removeSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // ── Convenience Getters ─────────────────────────────────────────────────

  String get language => getSetting(keyLanguage, 'am');
  Future<void> setLanguage(String lang) => setSetting(keyLanguage, lang);

  bool get isAmharic => language == 'am';

  bool get showGregorianDates => getSetting(keyShowGregorian, true);
  bool get showMoonPhase => getSetting(keyShowMoonPhase, true);
  bool get showEthiopianTime => getSetting(keyShowEthiopianTime, true);
  bool get enableFeastReminders => getSetting(keyEnableFeastReminders, true);
  bool get enableFastingReminders =>
      getSetting(keyEnableFastingReminders, true);
  bool get enableDailySaint => getSetting(keyEnableDailySaint, false);
  int get reminderAdvanceDays => getSetting(keyReminderAdvanceDays, 1);
  bool get onboardingComplete => getSetting(keyOnboardingComplete, false);

  // ── Cache API (for expensive Bahire Hasab calculations) ─────────────────

  /// Cache a JSON-serializable object under a namespaced key
  /// e.g. cacheKey('movable_feasts', 2017) -> "movable_feasts_2017"
  String _cacheKey(String namespace, int year) => '${namespace}_$year';

  Future<void> cacheJson(String namespace, int year, Map<String, dynamic> data) async {
    await _cacheBox.put(_cacheKey(namespace, year), jsonEncode(data));
  }

  Map<String, dynamic>? getCachedJson(String namespace, int year) {
    final raw = _cacheBox.get(_cacheKey(namespace, year)) as String?;
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheList(String namespace, int year, List<dynamic> data) async {
    await _cacheBox.put(_cacheKey(namespace, year), jsonEncode(data));
  }

  List<dynamic>? getCachedList(String namespace, int year) {
    final raw = _cacheBox.get(_cacheKey(namespace, year)) as String?;
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // ── Backup / Restore (Settings only — DB handled separately) ────────────

  Map<String, dynamic> exportSettings() {
    final map = <String, dynamic>{};
    for (final key in _settingsBox.keys) {
      map[key.toString()] = _settingsBox.get(key);
    }
    return map;
  }

  Future<void> importSettings(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _settingsBox.put(entry.key, entry.value);
    }
  }

  Future<void> clearAllSettings() async {
    await _settingsBox.clear();
  }
}