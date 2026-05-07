import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_alert_item.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notifications {
    return _firestore.collection('notifications');
  }

  Stream<QuerySnapshot> notificationStream() {
    return _notifications
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  int daysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  List<NotificationAlertItem> buildAlertsFromInventory(
    List<QueryDocumentSnapshot> docs,
  ) {
    final alerts = <NotificationAlertItem>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? 'Item').toString();
      final quantity = data['quantity'] ?? 0;
      final expiryRaw = data['expiryDate'];

      if (expiryRaw is Timestamp) {
        final days = daysLeft(expiryRaw.toDate());

        if (days >= 0 && days <= 4) {
          alerts.add(
            NotificationAlertItem(
              id: 'expiry_${doc.id}',
              title: days == 0
                  ? 'Expires Today'
                  : days == 1
                  ? 'Expires Tomorrow'
                  : 'Expires in $days Days',
              message: '$name expires soon.',
              type: AlertType.expiry,
              priority: days <= 1 ? AlertPriority.high : AlertPriority.medium,
              isRead: false,
              isDismissed: false,
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      if (quantity <= 0) {
        alerts.add(
          NotificationAlertItem(
            id: 'stock_out_${doc.id}',
            title: 'Out of Stock',
            message: '$name is out of stock.',
            type: AlertType.stock,
            priority: AlertPriority.high,
            isRead: false,
            isDismissed: false,
            createdAt: DateTime.now(),
          ),
        );
      } else if (quantity <= 2) {
        alerts.add(
          NotificationAlertItem(
            id: 'low_stock_${doc.id}',
            title: 'Low Stock',
            message: '$name is running low. Only $quantity left.',
            type: AlertType.stock,
            priority: AlertPriority.medium,
            isRead: false,
            isDismissed: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return alerts;
  }

  Future<void> syncMissingNotifications(
    List<NotificationAlertItem> alerts,
  ) async {
    for (final alert in alerts) {
      final ref = _notifications.doc(alert.id);
      final snap = await ref.get();

      if (!snap.exists) {
        await ref.set(alert.toFirestore());
      } else {
        await ref.set({
          'title': alert.title,
          'message': alert.message,
          'type': alert.type.name,
          'priority': alert.priority.name,
          'priorityRank': _priorityRank(alert.priority),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> toggleRead(NotificationAlertItem alert) async {
    await _notifications.doc(alert.id).update({'isRead': !alert.isRead});
  }

  Future<void> markAllAsRead(List<NotificationAlertItem> alerts) async {
    final batch = _firestore.batch();

    for (final alert in alerts) {
      batch.update(_notifications.doc(alert.id), {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> dismiss(NotificationAlertItem alert) async {
    await _notifications.doc(alert.id).update({'isDismissed': true});
  }

  int _priorityRank(AlertPriority priority) {
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
