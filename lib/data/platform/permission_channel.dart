import 'package:flutter/services.dart';
import '../../core/constants/channel_constants.dart';
import '../../domain/enums/permission_type.dart';

/// Dart wrapper for the permissions platform channel.
class PermissionChannel {
  static const _channel = MethodChannel(ChannelConstants.permissions);

  /// Check if a specific permission is granted.
  Future<bool> checkPermission(PermissionType type) async {
    final result = await _channel.invokeMethod<bool>(
      ChannelConstants.checkPermission,
      {'type': type.key},
    );
    return result ?? false;
  }

  /// Request a specific permission (opens settings/dialog).
  /// Returns true if the permission was granted.
  Future<bool> requestPermission(PermissionType type) async {
    final result = await _channel.invokeMethod<bool>(
      ChannelConstants.requestPermission,
      {'type': type.key},
    );
    return result ?? false;
  }

  /// Check all permission statuses at once.
  Future<Map<PermissionType, bool>> checkAllPermissions() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        ChannelConstants.checkAllPermissions);
    if (result == null) {
      return {for (final type in PermissionType.values) type: false};
    }
    final map = Map<String, bool>.from(result);
    return {
      for (final type in PermissionType.values)
        type: map[type.key] ?? false,
    };
  }
}
