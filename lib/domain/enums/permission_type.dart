/// Permission types the app requests from the user.
enum PermissionType {
  usageStats('usage_stats', 'Usage Access',
      'Required to detect which apps you use and for how long.'),
  notification('notification', 'Notifications',
      'Allows the tracking service to run and alert you about temperature.'),
  batteryOptimization('battery_optimization', 'Battery Optimization',
      'Prevents Android from killing the tracking service in the background.');

  const PermissionType(this.key, this.displayName, this.explanation);

  /// Key used in platform channel calls.
  final String key;

  /// Human-readable name for the UI.
  final String displayName;

  /// Explanation shown to the user during onboarding.
  final String explanation;
}
