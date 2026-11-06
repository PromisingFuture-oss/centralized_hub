import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../data/platform/battery_channel.dart';
import '../../data/platform/thermal_channel.dart';
import '../../data/platform/tracking_service_channel.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/sample_repository.dart';
import '../../data/repositories/settings_repository.dart';

/// Orchestrates session lifecycle: start/end sessions, process samples
/// from the native foreground service, and manage the tracking service.
class SessionTrackerService {
  final AppRepository _appRepository;
  final SessionRepository _sessionRepository;
  final SampleRepository _sampleRepository;
  final SettingsRepository _settingsRepository;
  final TrackingServiceChannel _trackingChannel;
  final BatteryChannel _batteryChannel;
  final ThermalChannel _thermalChannel;

  StreamSubscription<TrackingEvent>? _trackingSubscription;
  int? _activeSessionId;

  SessionTrackerService({
    required AppRepository appRepository,
    required SessionRepository sessionRepository,
    required SampleRepository sampleRepository,
    required SettingsRepository settingsRepository,
    required TrackingServiceChannel trackingChannel,
    required BatteryChannel batteryChannel,
    required ThermalChannel thermalChannel,
  })  : _appRepository = appRepository,
        _sessionRepository = sessionRepository,
        _sampleRepository = sampleRepository,
        _settingsRepository = settingsRepository,
        _trackingChannel = trackingChannel,
        _batteryChannel = batteryChannel,
        _thermalChannel = thermalChannel;

  /// Start listening to tracking events and ensure the service is running.
  Future<void> initialize() async {
    // Check for any unclosed session (app was killed)
    final activeSession = await _sessionRepository.getActiveSession();
    if (activeSession != null) {
      _activeSessionId = activeSession.id;
    }

    // Start listening to native tracking events
    _trackingSubscription?.cancel();
    _trackingSubscription =
        _trackingChannel.trackingEvents.listen(_handleTrackingEvent);

    // Ensure the foreground service is running if tracking is enabled
    final isEnabled = await _settingsRepository.isTrackingEnabled();
    if (isEnabled) {
      final intervalMs = await _settingsRepository.getSampleIntervalMs();
      final games = await _appRepository.getGames();
      final gamePackages = games.map((g) => g.packageName).toList();
      final isRunning = await _trackingChannel.isRunning();
      if (!isRunning) {
        await _trackingChannel.startService(
          intervalMs: intervalMs,
          gamePackages: gamePackages,
        );
      } else {
        await _trackingChannel.updateGamePackages(gamePackages);
      }
    }
  }

  /// Handle events from the native tracking service.
  void _handleTrackingEvent(TrackingEvent event) {
    if (event.isSessionStart) {
      _onSessionStart(event.data);
    } else if (event.isSessionEnd) {
      _onSessionEnd(event.data);
    } else if (event.isSample) {
      _onSample(event.data);
    }
  }

  /// Called when a tracked game comes to the foreground.
  Future<void> _onSessionStart(Map<String, dynamic> data) async {
    final packageName = data['packageName'] as String? ?? '';
    final appName = data['appName'] as String? ?? packageName;
    final isGame = data['isGame'] as bool? ?? true;

    if (packageName.isEmpty) return;

    // Ensure the app exists in our DB
    final appId = await _appRepository.ensureApp(
      packageName: packageName,
      appName: appName,
      isGame: isGame,
    );

    // Check if we should resume a recent session (within resume window)
    final lastSession = await _sessionRepository.getLastSessionForApp(appId);
    if (lastSession != null &&
        lastSession.endTime != null &&
        DateTime.now().difference(lastSession.endTime!).inMilliseconds <
            AppConstants.sessionResumeWindowMs) {
      // Resume: reopen the session by clearing its end time
      // For simplicity, we just use the existing session
      _activeSessionId = lastSession.id;
      return;
    }

    // Get battery info for session start
    BatteryInfo? batteryInfo;
    try {
      batteryInfo = await _batteryChannel.getBatteryInfo();
    } catch (_) {
      // Battery info not available
    }

    // Create a new session
    final sessionId = await _sessionRepository.createSession(
      appId: appId,
      startTime: DateTime.now(),
      batteryStart: batteryInfo?.level,
      wasChargingStart: batteryInfo?.isCharging ?? false,
    );
    _activeSessionId = sessionId;

    // Immediately record the initial sample so temperature is captured from start
    final startTempC = (batteryInfo != null && batteryInfo.temperatureC > 0)
        ? batteryInfo.temperatureC
        : (data['batteryTempC'] as num?)?.toDouble();
    final startLevel = batteryInfo?.level ?? (data['batteryLevel'] as int?);
    final startCharging =
        batteryInfo?.isCharging ?? (data['isCharging'] as bool? ?? false);

    if (startTempC != null || startLevel != null) {
      await _sampleRepository.insertSample(
        sessionId: sessionId,
        timestamp: DateTime.now(),
        batteryLevel: startLevel,
        batteryTempC: startTempC,
        isCharging: startCharging,
      );
    }
  }

  /// Called when a tracked game leaves the foreground.
  Future<void> _onSessionEnd(Map<String, dynamic> data) async {
    final sessionId = _activeSessionId;
    if (sessionId == null) return;

    // Get battery info for session end
    BatteryInfo? batteryInfo;
    try {
      batteryInfo = await _batteryChannel.getBatteryInfo();
    } catch (_) {}

    // Record the ending sample
    final endTempC = (batteryInfo != null && batteryInfo.temperatureC > 0)
        ? batteryInfo.temperatureC
        : (data['batteryTempC'] as num?)?.toDouble();
    final endLevel = batteryInfo?.level ?? (data['batteryLevel'] as int?);
    final endCharging =
        batteryInfo?.isCharging ?? (data['isCharging'] as bool? ?? false);

    if (endTempC != null || endLevel != null) {
      await _sampleRepository.insertSample(
        sessionId: sessionId,
        timestamp: DateTime.now(),
        batteryLevel: endLevel,
        batteryTempC: endTempC,
        isCharging: endCharging,
      );
    }

    await _sessionRepository.endSession(
      sessionId: sessionId,
      endTime: DateTime.now(),
      batteryEnd: endLevel,
      wasChargingEnd: endCharging,
    );

    _activeSessionId = null;

    // Clean up short sessions
    final minDuration =
        await _settingsRepository.getMinSessionDurationMs();
    await _sessionRepository.deleteShortSessions(minDuration);
  }

  /// Called when the service takes a temperature/battery sample.
  Future<void> _onSample(Map<String, dynamic> data) async {
    final sessionId = _activeSessionId;
    if (sessionId == null) return;

    final batteryLevel = data['batteryLevel'] as int?;
    final batteryTempC = (data['batteryTempC'] as num?)?.toDouble();
    final isCharging = data['isCharging'] as bool? ?? false;
    final thermalStatus = data['thermalStatus'] as int?;

    await _sampleRepository.insertSample(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      batteryLevel: batteryLevel,
      batteryTempC: batteryTempC,
      isCharging: isCharging,
      thermalStatus: thermalStatus,
    );
  }

  /// Start the tracking service.
  Future<void> startTracking() async {
    final intervalMs = await _settingsRepository.getSampleIntervalMs();
    final games = await _appRepository.getGames();
    final gamePackages = games.map((g) => g.packageName).toList();
    await _trackingChannel.startService(
      intervalMs: intervalMs,
      gamePackages: gamePackages,
    );
    await _settingsRepository.setTrackingEnabled(true);
  }

  /// Stop the tracking service.
  Future<void> stopTracking() async {
    // End any active session
    if (_activeSessionId != null) {
      await _onSessionEnd({});
    }
    await _trackingChannel.stopService();
    await _settingsRepository.setTrackingEnabled(false);
  }

  /// Whether the service is currently running.
  Future<bool> isRunning() => _trackingChannel.isRunning();

  /// Get the active session ID, if any.
  int? get activeSessionId => _activeSessionId;

  /// Thermal channel accessor.
  ThermalChannel get thermalChannel => _thermalChannel;

  /// Clean up resources.
  void dispose() {
    _trackingSubscription?.cancel();
  }
}
