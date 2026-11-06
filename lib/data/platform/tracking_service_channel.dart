import 'package:flutter/services.dart';
import '../../core/constants/channel_constants.dart';

/// Tracking event sent from the native foreground service.
class TrackingEvent {
  final String event; // "session_start", "session_end", "sample"
  final Map<String, dynamic> data;

  const TrackingEvent({required this.event, required this.data});

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      event: map['event'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }

  bool get isSessionStart => event == 'session_start';
  bool get isSessionEnd => event == 'session_end';
  bool get isSample => event == 'sample';
}

/// Dart wrapper for the tracking foreground service platform channel.
class TrackingServiceChannel {
  static const _methodChannel =
      MethodChannel(ChannelConstants.trackingService);
  static const _eventChannel =
      EventChannel(ChannelConstants.trackingEvents);

  /// Start the foreground tracking service.
  Future<bool> startService({
    required int intervalMs,
    List<String>? gamePackages,
  }) async {
    final result = await _methodChannel.invokeMethod<bool>(
      ChannelConstants.startService,
      {
        'intervalMs': intervalMs,
        'gamePackages': gamePackages ?? [],
      },
    );
    return result ?? false;
  }

  /// Update the list of packages considered games in the native service.
  Future<void> updateGamePackages(List<String> gamePackages) async {
    await _methodChannel.invokeMethod<void>(
      ChannelConstants.updateGamePackages,
      {'gamePackages': gamePackages},
    );
  }

  /// Stop the foreground tracking service.
  Future<void> stopService() async {
    await _methodChannel.invokeMethod<void>(ChannelConstants.stopService);
  }

  /// Check if the service is currently running.
  Future<bool> isRunning() async {
    final result = await _methodChannel
        .invokeMethod<bool>(ChannelConstants.isServiceRunning);
    return result ?? false;
  }

  /// Update the sampling interval without restarting the service.
  Future<void> updateInterval({required int intervalMs}) async {
    await _methodChannel.invokeMethod<void>(
      ChannelConstants.updateInterval,
      {'intervalMs': intervalMs},
    );
  }

  /// Stream of tracking events from the native service.
  Stream<TrackingEvent> get trackingEvents {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return TrackingEvent.fromMap(
          Map<String, dynamic>.from(event as Map));
    });
  }
}
