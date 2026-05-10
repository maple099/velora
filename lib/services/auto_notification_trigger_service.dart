import 'package:cloud_firestore/cloud_firestore.dart';

import 'local_notification_service.dart';

class AutoNotificationTriggerService {
  AutoNotificationTriggerService._();

  static final Set<String> _triggeredIds = {};

  static Future<void> checkAndTriggerUnreadAlerts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('isDismissed', isEqualTo: false)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) return;

    final docs = snapshot.docs;

    final highPriorityDocs = docs.where((doc) {
      final data = doc.data();
      return data['priority'] == 'high';
    }).toList();

    final selected = highPriorityDocs.isNotEmpty
        ? highPriorityDocs.first
        : docs.first;

    if (_triggeredIds.contains(selected.id)) return;

    final data = selected.data();

    final title = (data['title'] ?? 'Velora Alert').toString();
    final message =
        (data['message'] ?? 'You have inventory items that need attention.')
            .toString();

    await LocalNotificationService.showNotification(
      title: title,
      body: message,
    );

    _triggeredIds.add(selected.id);
  }
}
