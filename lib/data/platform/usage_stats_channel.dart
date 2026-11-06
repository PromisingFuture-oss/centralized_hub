import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/channel_constants.dart';

/// Dart wrapper for the Android UsageStatsManager platform channel.
class UsageStatsChannel {
  static const _channel = MethodChannel(ChannelConstants.usageStats);

  /// Check if PACKAGE_USAGE_STATS permission is granted.
  Future<bool> hasPermission() async {
    final result = await _channel.invokeMethod<bool>(
        ChannelConstants.hasUsagePermission);
    return result ?? false;
  }

  /// Open the system Usage Access settings page.
  Future<void> openPermissionSettings() async {
    await _channel.invokeMethod<void>(ChannelConstants.openUsageSettings);
  }

  /// Get installed apps, optionally filtering for games only.
  /// Returns a list of maps with keys: packageName, appName, isGame, iconBase64.
  Future<List<Map<String, dynamic>>> getInstalledApps({
    bool gamesOnly = false,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      ChannelConstants.getInstalledApps,
      {'gamesOnly': gamesOnly},
    );
    return result
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  /// Get usage events within a time range.
  /// Returns list of maps with keys: eventType, packageName, timestamp.
  Future<List<Map<String, dynamic>>> getUsageEvents({
    required int startTime,
    required int endTime,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      ChannelConstants.getUsageEvents,
      {'startTime': startTime, 'endTime': endTime},
    );
    return result
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  /// Get the currently foreground app's package name, or null.
  Future<String?> getCurrentForegroundPackage() async {
    return await _channel.invokeMethod<String?>(
        ChannelConstants.getCurrentForegroundPackage);
  }

  /// Launch an installed application by package name directly.
  Future<bool> launchApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        ChannelConstants.launchApp,
        {'packageName': packageName},
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Parse a base64 icon string to bytes.
  static Uint8List? parseIcon(String? iconBase64) {
    if (iconBase64 == null || iconBase64.isEmpty) return null;
    try {
      return base64Decode(iconBase64);
    } catch (_) {
      return null;
    }
  }
}
