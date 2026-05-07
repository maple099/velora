import 'package:flutter/material.dart';

import '../../services/notification_alert_service.dart';

class NotificationPage extends StatelessWidget {
  final List<NearExpiryAlert> nearExpiryAlerts;
  final List<LowStockAlert> lowStockAlerts;

  const NotificationPage({
    super.key,
    required this.nearExpiryAlerts,
    required this.lowStockAlerts,
  });

  static const Color bg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color purple = Color(0xFF7C3AED);
  static const Color border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final total = nearExpiryAlerts.length + lowStockAlerts.length;

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
      body: total == 0 ? _emptyState() : _historyList(total),
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
                border: Border.all(color: border),
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

  Widget _historyList(int total) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        _summaryHeader(total),
        const SizedBox(height: 18),

        if (nearExpiryAlerts.isNotEmpty)
          _sectionTitle(
            icon: Icons.schedule_rounded,
            title: 'Near Expiry Alerts',
            count: nearExpiryAlerts.length,
            color: Colors.orange,
          ),

        if (nearExpiryAlerts.isNotEmpty) const SizedBox(height: 12),

        for (final alert in nearExpiryAlerts)
          _notificationCard(
            icon: Icons.schedule_rounded,
            iconColor: Colors.orange,
            title: _nearExpiryTitle(alert.daysLeft),
            message: alert.message,
          ),

        if (nearExpiryAlerts.isNotEmpty && lowStockAlerts.isNotEmpty)
          const SizedBox(height: 8),

        if (lowStockAlerts.isNotEmpty)
          _sectionTitle(
            icon: Icons.warning_amber_rounded,
            title: 'Low Stock Alerts',
            count: lowStockAlerts.length,
            color: Colors.redAccent,
          ),

        if (lowStockAlerts.isNotEmpty) const SizedBox(height: 12),

        for (final alert in lowStockAlerts)
          _notificationCard(
            icon: Icons.warning_amber_rounded,
            iconColor: alert.quantity <= 0 ? Colors.red : Colors.redAccent,
            title: alert.quantity <= 0 ? 'Out of Stock' : 'Low Stock',
            message: alert.message,
          ),
      ],
    );
  }

  Widget _summaryHeader(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purple, Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total active alert(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review items that need attention today.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.8,
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

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
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
        border: Border.all(color: border),
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

  String _nearExpiryTitle(int daysLeft) {
    if (daysLeft == 0) return 'Expires Today';
    if (daysLeft == 1) return 'Expires Tomorrow';
    return 'Expiring Soon';
  }
}
