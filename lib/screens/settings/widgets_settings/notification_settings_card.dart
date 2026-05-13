import 'package:flutter/material.dart';

import '../../settings/widgets_settings/settings_section_card.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool nearExpiryAlerts;
  final bool lowStockAlerts;
  final bool activityUpdates;

  final ValueChanged<bool> onNearExpiryChanged;
  final ValueChanged<bool> onLowStockChanged;
  final ValueChanged<bool> onActivityChanged;

  const NotificationSettingsCard({
    super.key,
    required this.nearExpiryAlerts,
    required this.lowStockAlerts,
    required this.activityUpdates,
    required this.onNearExpiryChanged,
    required this.onLowStockChanged,
    required this.onActivityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Notification Settings',
      children: [
        _NotificationSwitchTile(
          icon: Icons.event_busy_rounded,
          title: 'Near Expiry Alerts',
          subtitle: 'Notify when items are close to expiry',
          value: nearExpiryAlerts,
          onChanged: onNearExpiryChanged,
        ),
        _NotificationSwitchTile(
          icon: Icons.inventory_2_outlined,
          title: 'Low Stock Alerts',
          subtitle: 'Notify when stock quantity is low',
          value: lowStockAlerts,
          onChanged: onLowStockChanged,
        ),
        _NotificationSwitchTile(
          icon: Icons.history_rounded,
          title: 'Activity Updates',
          subtitle: 'Notify about inventory activity changes',
          value: activityUpdates,
          onChanged: onActivityChanged,
        ),
      ],
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF7C3AED),
      secondary: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF7C3AED)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
    );
  }
}
