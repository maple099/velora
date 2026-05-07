import 'package:flutter/material.dart';

import '../notification_alert_item.dart';

class NotificationPriorityChip extends StatelessWidget {
  final AlertPriority priority;

  const NotificationPriorityChip({super.key, required this.priority});

  Color get color {
    switch (priority) {
      case AlertPriority.high:
        return const Color(0xFFEF4444);
      case AlertPriority.medium:
        return const Color(0xFFF59E0B);
      case AlertPriority.low:
        return const Color(0xFF10B981);
    }
  }

  String get text {
    switch (priority) {
      case AlertPriority.high:
        return 'High';
      case AlertPriority.medium:
        return 'Medium';
      case AlertPriority.low:
        return 'Low';
    }
  }

  IconData get icon {
    switch (priority) {
      case AlertPriority.high:
        return Icons.priority_high_rounded;
      case AlertPriority.medium:
        return Icons.remove_rounded;
      case AlertPriority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
