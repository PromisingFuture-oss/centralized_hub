import 'package:flutter/services.dart';
import '../../core/constants/channel_constants.dart';

/// Dart wrapper for the PowerManager thermal status channel.
class ThermalChannel {
  static const _channel = MethodChannel(ChannelConstants.thermal);

  /// Whether the thermal API is available (API 29+).
  Future<bool> isThermalApiAvailable() async {
    final result = await _channel
        .invokeMethod<bool>(ChannelConstants.isThermalApiAvailable);
    return result ?? false;
  }

  /// Get current thermal status.
  /// Returns null if API not available.
  /// Values: 0=NONE, 1=LIGHT, 2=MODERATE, 3=SEVERE, 4=CRITICAL, 5=EMERGENCY, 6=SHUTDOWN
  Future<int?> getCurrentThermalStatus() async {
    return await _channel
        .invokeMethod<int?>(ChannelConstants.getCurrentThermalStatus);
  }

  /// Human-readable label for a thermal status value.
  static String thermalStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'None';
      case 1:
        return 'Light';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      case 4:
        return 'Critical';
      case 5:
        return 'Emergency';
      case 6:
        return 'Shutdown';
      default:
        return 'Unknown';
    }
  }
}
