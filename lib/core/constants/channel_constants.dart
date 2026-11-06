/// Platform channel names and method identifiers.
class ChannelConstants {
  ChannelConstants._();

  // Channel names
  static const String usageStats = 'com.centralizedhub/usage_stats';
  static const String battery = 'com.centralizedhub/battery';
  static const String batteryStream = 'com.centralizedhub/battery_stream';
  static const String thermal = 'com.centralizedhub/thermal';
  static const String permissions = 'com.centralizedhub/permissions';
  static const String trackingService = 'com.centralizedhub/tracking_service';
  static const String trackingEvents = 'com.centralizedhub/tracking_events';

  // Usage Stats methods
  static const String hasUsagePermission = 'hasPermission';
  static const String openUsageSettings = 'openPermissionSettings';
  static const String getInstalledApps = 'getInstalledApps';
  static const String getUsageEvents = 'getUsageEvents';
  static const String getCurrentForegroundPackage = 'getCurrentForegroundPackage';
  static const String launchApp = 'launchApp';

  // Battery methods
  static const String getBatteryInfo = 'getBatteryInfo';

  // Thermal methods
  static const String isThermalApiAvailable = 'isThermalApiAvailable';
  static const String getCurrentThermalStatus = 'getCurrentThermalStatus';

  // Permission methods
  static const String checkPermission = 'checkPermission';
  static const String requestPermission = 'requestPermission';
  static const String checkAllPermissions = 'checkAllPermissions';

  // Tracking service methods
  static const String startService = 'startService';
  static const String stopService = 'stopService';
  static const String isServiceRunning = 'isRunning';
  static const String updateInterval = 'updateInterval';
  static const String updateGamePackages = 'updateGamePackages';
}
