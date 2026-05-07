import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notification_alert_item.dart';
import 'widgets_notification/notification_alert_card.dart';
import 'widgets_notification/notification_empty_view.dart';
import 'widgets_notification/notification_header_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Set<String> _dismissedIds = {};
  final Set<String> _readIds = {};

  int _daysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  List<NotificationAlertItem> _buildAlerts(List<QueryDocumentSnapshot> docs) {
    final alerts = <NotificationAlertItem>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? 'Item').toString();
      final quantity = data['quantity'] ?? 0;
      final expiryRaw = data['expiryDate'];

      if (expiryRaw is Timestamp) {
        final days = _daysLeft(expiryRaw.toDate());

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
          ),
        );
      }
    }

    return alerts.where((item) => !_dismissedIds.contains(item.id)).toList();
  }

  void _toggleRead(String id) {
    setState(() {
      if (_readIds.contains(id)) {
        _readIds.remove(id);
      } else {
        _readIds.add(id);
      }
    });
  }

  void _dismiss(String id) {
    setState(() {
      _dismissedIds.add(id);
    });
  }

  void _readAll(List<NotificationAlertItem> alerts) {
    setState(() {
      for (final alert in alerts) {
        _readIds.add(alert.id);
      }
    });
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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = _buildAlerts(snapshot.data!.docs);
          final unreadCount = alerts
              .where((item) => !_readIds.contains(item.id))
              .length;

          return Column(
            children: [
              NotificationHeaderCard(
                total: alerts.length,
                unread: unreadCount,
                onReadAll: () => _readAll(alerts),
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
                            isRead: _readIds.contains(alert.id),
                            onToggleRead: () => _toggleRead(alert.id),
                            onDismiss: () => _dismiss(alert.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
