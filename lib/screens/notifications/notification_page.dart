import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notification_alert_item.dart';
import 'notification_service.dart';
import 'widgets_notification/notification_alert_card.dart';
import 'widgets_notification/notification_empty_view.dart';
import 'widgets_notification/notification_header_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _service = NotificationService();

  bool _isSyncing = false;

  Future<void> _syncInventoryAlerts(List<QueryDocumentSnapshot> docs) async {
    if (_isSyncing) return;

    _isSyncing = true;

    final alerts = _service.buildAlertsFromInventory(docs);
    await _service.syncMissingNotifications(alerts);

    _isSyncing = false;
  }

  List<NotificationAlertItem> _activeAlerts(QuerySnapshot snapshot) {
    return snapshot.docs
        .map(NotificationAlertItem.fromDoc)
        .where((item) => !item.isDismissed)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, inventorySnapshot) {
          if (!inventorySnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncInventoryAlerts(inventorySnapshot.data!.docs);
          });

          return StreamBuilder<QuerySnapshot>(
            stream: _service.notificationStream(),
            builder: (context, notificationSnapshot) {
              if (!notificationSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final alerts = _activeAlerts(notificationSnapshot.data!);
              final unreadCount = alerts.where((item) => !item.isRead).length;

              return Column(
                children: [
                  NotificationHeaderCard(
                    total: alerts.length,
                    unread: unreadCount,
                    onReadAll: () => _service.markAllAsRead(alerts),
                  ),
                  Expanded(
                    child: alerts.isEmpty
                        ? const NotificationEmptyView()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];

                              return NotificationAlertCard(
                                alert: alert,
                                isRead: alert.isRead,
                                onToggleRead: () => _service.toggleRead(alert),
                                onDismiss: () => _service.dismiss(alert),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
