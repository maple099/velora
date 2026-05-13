class ExpiryHelper {
  static int daysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  static String daysLeftText(DateTime expiryDate) {
    final days = daysLeft(expiryDate);

    if (days < 0) return 'Expired ${days.abs()} days ago';
    if (days == 0) return 'Expires today';
    if (days == 1) return '1 day left';

    return '$days days left';
  }
}
