/// Utilities for formatting durations in a human-readable way.
class DurationFormatter {
  DurationFormatter._();

  /// Format milliseconds as "1h 23m" or "45m" or "30s".
  static String formatMs(int? ms) {
    if (ms == null || ms <= 0) return '0s';
    return format(Duration(milliseconds: ms));
  }

  /// Format a Duration as "1h 23m" or "45m" or "30s".
  static String format(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Format as "1 hour 23 minutes" (long form).
  static String formatLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    }
    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    }
    if (parts.isEmpty && seconds > 0) {
      parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }
    return parts.isEmpty ? '0 seconds' : parts.join(' ');
  }

  /// Format as "HH:MM:SS" for live session timer.
  static String formatTimer(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
