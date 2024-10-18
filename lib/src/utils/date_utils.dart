
DateTime getStartOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime getEndOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59);
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}