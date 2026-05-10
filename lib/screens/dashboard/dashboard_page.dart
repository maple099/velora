import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auto_notification_trigger_service.dart';
import '../home/widgets_home/notification_bell.dart';
import '../home/widgets_home/recent_activity_card.dart';
import '../inventory/add_item/add_item_page.dart';
import '../inventory/inventory_page.dart';
import '../notifications/notification_page.dart';
import '../suggestions/suggestions_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);

  int _daysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  int _nearExpiryCount(List<QueryDocumentSnapshot> docs) {
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiryRaw = data['expiryDate'];

      if (expiryRaw is Timestamp) {
        final days = _daysLeft(expiryRaw.toDate());
        if (days >= 0 && days <= 4) count++;
      }
    }

    return count;
  }

  int _lowStockCount(List<QueryDocumentSnapshot> docs) {
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final quantity = data['quantity'] ?? 0;

      if (quantity <= 2) count++;
    }

    return count;
  }

  void _goTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _triggerAutoNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AutoNotificationTriggerService.checkAndTriggerUnreadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('inventory')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final totalItems = docs.length;
            final nearExpiry = _nearExpiryCount(docs);
            final lowStock = _lowStockCount(docs);

            _triggerAutoNotification();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const _DashboardHeader(),
                const SizedBox(height: 18),
                _HeroCard(totalItems: totalItems),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Near Expiry',
                        value: nearExpiry.toString(),
                        icon: Icons.access_time_rounded,
                        color: orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Low Stock',
                        value: lowStock.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _QuickActions(
                  onAddTap: () => _goTo(context, const AddItemPage()),
                  onInventoryTap: () => _goTo(context, const InventoryPage()),
                  onSuggestionTap: () =>
                      _goTo(context, const SuggestionsPage()),
                  onAlertTap: () => _goTo(context, const NotificationPage()),
                ),
                const SizedBox(height: 18),
                const RecentActivityCard(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back 👋',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Velora Dashboard',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        NotificationBell(),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int totalItems;

  const _HeroCard({required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(55),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$totalItems item(s)\ncurrently in inventory',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onInventoryTap;
  final VoidCallback onSuggestionTap;
  final VoidCallback onAlertTap;

  const _QuickActions({
    required this.onAddTap,
    required this.onInventoryTap,
    required this.onSuggestionTap,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                title: 'Add Item',
                icon: Icons.add_rounded,
                onTap: onAddTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                title: 'Inventory',
                icon: Icons.inventory_rounded,
                onTap: onInventoryTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                title: 'AI Suggestion',
                icon: Icons.auto_awesome_rounded,
                onTap: onSuggestionTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                title: 'Alerts',
                icon: Icons.notifications_rounded,
                onTap: onAlertTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
