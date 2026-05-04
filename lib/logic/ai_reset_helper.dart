class AiResetHelper {
  static Map<String, String> getResetInfo() {
    final now = DateTime.now();
    final resetTime = _nextGeminiResetMalaysiaTime(now);

    final diff = resetTime.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    final resetHour = resetTime.hour.toString().padLeft(2, '0');
    final resetMinute = resetTime.minute.toString().padLeft(2, '0');

    return {
      'countdown': '${hours}h ${minutes}m',
      'timeText': 'Resets around $resetHour:$resetMinute Malaysia time',
    };
  }

  static DateTime _nextGeminiResetMalaysiaTime(DateTime nowMalaysia) {
    final nowUtc = nowMalaysia.toUtc();
    final offset = _pacificOffsetHours(nowUtc);

    final nowPt = nowUtc.add(Duration(hours: offset));
    final resetPt = DateTime(nowPt.year, nowPt.month, nowPt.day + 1);

    final resetUtc = resetPt.subtract(Duration(hours: offset));
    return resetUtc.toLocal();
  }

  static int _pacificOffsetHours(DateTime utcDate) {
    final year = utcDate.year;
    final dstStart = _secondSundayOfMarchUtc(year);
    final dstEnd = _firstSundayOfNovemberUtc(year);

    final isDst = utcDate.isAfter(dstStart) && utcDate.isBefore(dstEnd);
    return isDst ? -7 : -8;
  }

  static DateTime _secondSundayOfMarchUtc(int year) {
    final marchFirst = DateTime.utc(year, 3, 1);
    final days = (DateTime.sunday - marchFirst.weekday) % 7;
    final secondSunday = marchFirst.add(Duration(days: days + 7));

    return DateTime.utc(
      secondSunday.year,
      secondSunday.month,
      secondSunday.day,
      10,
    );
  }

  static DateTime _firstSundayOfNovemberUtc(int year) {
    final novFirst = DateTime.utc(year, 11, 1);
    final days = (DateTime.sunday - novFirst.weekday) % 7;
    final firstSunday = novFirst.add(Duration(days: days));

    return DateTime.utc(
      firstSunday.year,
      firstSunday.month,
      firstSunday.day,
      9,
    );
  }
}
