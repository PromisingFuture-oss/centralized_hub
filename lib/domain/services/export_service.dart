import 'dart:convert';
import 'package:intl/intl.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/sample_repository.dart';

/// Service for exporting session data as CSV or JSON.
class ExportService {
  final AppRepository _appRepository;
  final SessionRepository _sessionRepository;
  final SampleRepository _sampleRepository;

  ExportService({
    required AppRepository appRepository,
    required SessionRepository sessionRepository,
    required SampleRepository sampleRepository,
  })  : _appRepository = appRepository,
        _sessionRepository = sessionRepository,
        _sampleRepository = sampleRepository;

  /// Export all sessions as CSV string.
  Future<String> exportSessionsCsv() async {
    final apps = await _appRepository.getAllApps();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    final buffer = StringBuffer();
    buffer.writeln(
        'App Name,Package Name,Start Time,End Time,Duration (min),Battery Start %,Battery End %,Battery Drop %,Was Charging,Temp Min °C,Temp Avg °C,Temp Max °C');

    for (final app in apps) {
      final sessions = await _sessionRepository.getSessionsForApp(app.id);
      for (final session in sessions) {
        if (session.endTime == null) continue; // skip active sessions
        final durationMin = (session.durationMs ?? 0) / 60000;
        buffer.writeln([
          _csvEscape(app.appName),
          _csvEscape(app.packageName),
          dateFormat.format(session.startTime),
          dateFormat.format(session.endTime!),
          durationMin.toStringAsFixed(1),
          session.batteryStart?.toString() ?? '',
          session.batteryEnd?.toString() ?? '',
          session.batteryDrop?.toString() ?? '',
          session.hadChargingDuring ? 'Yes' : 'No',
          session.tempMinC?.toStringAsFixed(1) ?? '',
          session.tempAvgC?.toStringAsFixed(1) ?? '',
          session.tempMaxC?.toStringAsFixed(1) ?? '',
        ].join(','));
      }
    }
    return buffer.toString();
  }

  /// Export all data as JSON string.
  Future<String> exportJson() async {
    final apps = await _appRepository.getAllApps();
    final exportData = <Map<String, dynamic>>[];

    for (final app in apps) {
      final sessions = await _sessionRepository.getSessionsForApp(app.id);
      final sessionData = <Map<String, dynamic>>[];

      for (final session in sessions) {
        if (session.endTime == null) continue;
        final samples =
            await _sampleRepository.getSamplesForSession(session.id);

        sessionData.add({
          'start_time': session.startTime.toIso8601String(),
          'end_time': session.endTime?.toIso8601String(),
          'duration_ms': session.durationMs,
          'battery_start': session.batteryStart,
          'battery_end': session.batteryEnd,
          'battery_drop': session.batteryDrop,
          'was_charging_start': session.wasChargingStart,
          'was_charging_end': session.wasChargingEnd,
          'had_charging_during': session.hadChargingDuring,
          'temp_min_c': session.tempMinC,
          'temp_avg_c': session.tempAvgC,
          'temp_max_c': session.tempMaxC,
          'thermal_status_max': session.thermalStatusMax,
          'samples': samples
              .map((s) => {
                    'timestamp': s.timestamp.toIso8601String(),
                    'battery_level': s.batteryLevel,
                    'battery_temp_c': s.batteryTempC,
                    'is_charging': s.isCharging,
                    'thermal_status': s.thermalStatus,
                  })
              .toList(),
        });
      }

      exportData.add({
        'package_name': app.packageName,
        'app_name': app.appName,
        'is_game': app.isGame,
        'sessions': sessionData,
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'apps': exportData,
    });
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
