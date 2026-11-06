/// App-wide constants for Centralized Hub.
class AppConstants {
  AppConstants._();

  /// Minimum session duration to keep (ms). Sessions shorter than this are discarded.
  static const int minSessionDurationMs = 3000; // 3 seconds

  /// Default interval for temperature/battery sampling (ms).
  static const int defaultSampleIntervalMs = 30000; // 30 seconds

  /// Min/max configurable sample interval.
  static const int minSampleIntervalMs = 15000; // 15 seconds
  static const int maxSampleIntervalMs = 60000; // 60 seconds

  /// If a game returns to foreground within this window, resume the session.
  static const int sessionResumeWindowMs = 60000; // 60 seconds

  /// How often the service polls UsageStatsManager for foreground changes (ms).
  static const int usageStatsPollIntervalMs = 5000; // 5 seconds

  /// Database name.
  static const String databaseName = 'centralized_hub.db';

  /// Default temperature alert threshold (°C) — null means disabled.
  static const double? defaultTempAlertThreshold = null;

  /// App display name.
  static const String appName = 'Centralized Hub';
}
