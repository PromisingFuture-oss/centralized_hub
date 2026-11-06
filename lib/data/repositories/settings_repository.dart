import '../database/daos/settings_dao.dart';

/// Repository for app settings, abstracting key-value store.
class SettingsRepository {
  final SettingsDao _settingsDao;

  SettingsRepository({required SettingsDao settingsDao})
      : _settingsDao = settingsDao;

  // --- Theme ---
  Future<String> getThemeMode() async =>
      _cleanString(await _settingsDao.getValue('theme_mode')) ?? 'system';

  Stream<String> watchThemeMode() =>
      _settingsDao.watchValue('theme_mode').map((v) => _cleanString(v) ?? 'system');

  Future<void> setThemeMode(String mode) =>
      _settingsDao.setValue('theme_mode', '"$mode"');

  // --- Accent Color ---
  Future<String> getAccentColor() async =>
      _cleanString(await _settingsDao.getValue('accent_color')) ?? '#6750A4';

  Stream<String> watchAccentColor() =>
      _settingsDao.watchValue('accent_color').map((v) => _cleanString(v) ?? '#6750A4');

  Future<void> setAccentColor(String hexColor) =>
      _settingsDao.setValue('accent_color', '"$hexColor"');

  // --- Temperature Unit ---
  Future<String> getTempUnit() async =>
      _cleanString(await _settingsDao.getValue('temp_unit')) ?? 'celsius';

  Stream<String> watchTempUnit() =>
      _settingsDao.watchValue('temp_unit').map((v) => _cleanString(v) ?? 'celsius');

  Future<void> setTempUnit(String unit) =>
      _settingsDao.setValue('temp_unit', '"$unit"');

  // --- Sample Interval ---
  Future<int> getSampleIntervalMs() async {
    final value = await _settingsDao.getValue('sample_interval_ms');
    return int.tryParse(value ?? '') ?? 30000;
  }

  Future<void> setSampleIntervalMs(int ms) =>
      _settingsDao.setValue('sample_interval_ms', '$ms');

  // --- Min Session Duration ---
  Future<int> getMinSessionDurationMs() async {
    final value = await _settingsDao.getValue('min_session_duration_ms');
    return int.tryParse(value ?? '') ?? 10000;
  }

  // --- Onboarding ---
  Future<bool> isOnboardingComplete() async {
    final value = _cleanString(await _settingsDao.getValue('onboarding_complete'));
    return value == 'true';
  }

  Stream<bool> watchOnboardingComplete() =>
      _settingsDao.watchValue('onboarding_complete').map((v) => _cleanString(v) == 'true');

  Future<void> setOnboardingComplete(bool complete) =>
      _settingsDao.setValue('onboarding_complete', '$complete');

  // --- Temp Alert ---
  Future<double?> getTempAlertThreshold() async {
    final value = await _settingsDao.getValue('temp_alert_threshold_c');
    if (value == null || value == 'null') return null;
    return double.tryParse(value);
  }

  Future<void> setTempAlertThreshold(double? threshold) =>
      _settingsDao.setValue(
          'temp_alert_threshold_c', threshold?.toString() ?? 'null');

  // --- Tracking ---
  Future<bool> isTrackingEnabled() async {
    final value = await _settingsDao.getValue('tracking_enabled');
    return value != 'false';
  }

  Future<void> setTrackingEnabled(bool enabled) =>
      _settingsDao.setValue('tracking_enabled', '$enabled');

  // --- Helpers ---
  /// Remove surrounding quotes from stored string values.
  String? _cleanString(String? value) {
    if (value == null) return null;
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}
