/// Time range for filtering dashboard data.
enum TimeRange {
  today('Today'),
  week('This Week'),
  month('This Month'),
  year('This Year'),
  allTime('All Time'),
  custom('Custom');

  const TimeRange(this.displayName);
  final String displayName;

  /// Returns the start DateTime for this range, relative to now.
  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case TimeRange.today:
        return DateTime(now.year, now.month, now.day);
      case TimeRange.week:
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
      case TimeRange.month:
        return DateTime(now.year, now.month, 1);
      case TimeRange.year:
        return DateTime(now.year, 1, 1);
      case TimeRange.allTime:
        return DateTime(2020, 1, 1);
      case TimeRange.custom:
        return now; // Caller should provide custom dates
    }
  }
}
