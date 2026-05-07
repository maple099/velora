import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { expiry, stock }

enum AlertPriority { high, medium, low }

class NotificationAlertItem {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;
  final bool isRead;
  final bool isDismissed;
  final DateTime createdAt;

  const NotificationAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.isDismissed,
    required this.createdAt,
  });

  factory NotificationAlertItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationAlertItem(
      id: doc.id,
      title: (data['title'] ?? 'Notification').toString(),
      message: (data['message'] ?? '').toString(),
      type: _typeFromString((data['type'] ?? '').toString()),
      priority: _priorityFromString((data['priority'] ?? '').toString()),
      isRead: data['isRead'] == true,
      isDismissed: data['isDismissed'] == true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'priorityRank': _priorityRank(priority),
      'isRead': isRead,
      'isDismissed': isDismissed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static AlertType _typeFromString(String value) {
    switch (value) {
      case 'expiry':
        return AlertType.expiry;
      case 'stock':
        return AlertType.stock;
      default:
        return AlertType.stock;
    }
  }

  static AlertPriority _priorityFromString(String value) {
    switch (value) {
      case 'high':
        return AlertPriority.high;
      case 'medium':
        return AlertPriority.medium;
      case 'low':
        return AlertPriority.low;
      default:
        return AlertPriority.medium;
    }
  }

  static int _priorityRank(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.high:
        return 1;
      case AlertPriority.medium:
        return 2;
      case AlertPriority.low:
        return 3;
    }
  }
}
