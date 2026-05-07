import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final int nearExpiryCount;
  final int lowStockCount;

  const NotificationPage({
    super.key,
    required this.nearExpiryCount,
    required this.lowStockCount,
  });

  static const Color bg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final total = nearExpiryCount + lowStockCount;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text(
          'Notifications',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900),
        ),
      ),
      body: total == 0 ? _emptyState() : _notificationList(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: purple,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications yet',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your food inventory looks safe for now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey, fontSize: 13.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const Text(
          'Today',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),

        if (nearExpiryCount > 0)
          _notificationCard(
            icon: Icons.schedule_rounded,
            iconColor: Colors.orange,
            title: 'Near expiry items',
            message:
                '$nearExpiryCount item(s) will expire soon. Check your inventory.',
          ),

        if (lowStockCount > 0)
          _notificationCard(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.redAccent,
            title: 'Low stock items',
            message:
                '$lowStockCount item(s) are running low. Consider restocking soon.',
          ),
      ],
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
