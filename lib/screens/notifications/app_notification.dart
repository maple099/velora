enum NotificationPriority { high, medium, low }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationPriority priority;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.priority,
    required this.isRead,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    NotificationPriority? priority,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
    );
  }
}
