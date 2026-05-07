enum AlertType { expiry, stock }

enum AlertPriority { high, medium, low }

class NotificationAlertItem {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;

  const NotificationAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
  });
}
