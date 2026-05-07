import 'package:flutter/material.dart';

import '../notification_alert_item.dart';
import 'notification_priority_chip.dart';

class NotificationAlertCard extends StatelessWidget {
  final NotificationAlertItem alert;
  final bool isRead;
  final VoidCallback onToggleRead;
  final VoidCallback onDismiss;

  const NotificationAlertCard({
    super.key,
    required this.alert,
    required this.isRead,
    required this.onToggleRead,
    required this.onDismiss,
  });

  Color get mainColor {
    switch (alert.priority) {
      case AlertPriority.high:
        return const Color(0xFFEF4444);
      case AlertPriority.medium:
        return const Color(0xFFF59E0B);
      case AlertPriority.low:
        return const Color(0xFF10B981);
    }
  }

  IconData get icon {
    switch (alert.type) {
      case AlertType.expiry:
        return Icons.access_time_rounded;
      case AlertType.stock:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFFC4B5FD),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: mainColor.withAlpha(25),
              child: Icon(icon, color: mainColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      NotificationPriorityChip(priority: alert.priority),
                      const Spacer(),
                      InkWell(
                        onTap: onToggleRead,
                        child: Text(
                          isRead ? 'Mark unread' : 'Mark read',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
