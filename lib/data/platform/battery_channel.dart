import 'package:flutter/services.dart';
import '../../core/constants/channel_constants.dart';

/// Battery information from a platform channel reading.
class BatteryInfo {
  final int level; // 0-100
  final double temperatureC; // °C
  final bool isCharging;
  final int voltage; // mV
  final int health;

  const BatteryInfo({
    required this.level,
    required this.temperatureC,
    required this.isCharging,
    required this.voltage,
    required this.health,
  });

  factory BatteryInfo.fromMap(Map<String, dynamic> map) {
    return BatteryInfo(
      level: map['level'] as int? ?? 0,
      temperatureC: (map['temperatureC'] as num?)?.toDouble() ?? 0.0,
      isCharging: map['isCharging'] as bool? ?? false,
      voltage: map['voltage'] as int? ?? 0,
      health: map['health'] as int? ?? 0,
    );
  }
}

/// Dart wrapper for battery platform channels (method + event).
class BatteryChannel {
  static const _methodChannel = MethodChannel(ChannelConstants.battery);
  static const _eventChannel = EventChannel(ChannelConstants.batteryStream);

  /// Get current battery info snapshot.
  Future<BatteryInfo> getBatteryInfo() async {
    final result = await _methodChannel
        .invokeMethod<Map<dynamic, dynamic>>(ChannelConstants.getBatteryInfo);
    return BatteryInfo.fromMap(Map<String, dynamic>.from(result ?? {}));
  }

  /// Stream battery changes (triggered by ACTION_BATTERY_CHANGED).
  Stream<BatteryInfo> get batteryStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return BatteryInfo.fromMap(Map<String, dynamic>.from(event as Map));
    });
  }
}
