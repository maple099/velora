import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/dashboard/recent_activity_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color mint = Color(0xFF10B981);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);

  int _nearExpiryCount(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiry = data['expiryDate'];

      if (expiry is Timestamp) {
        final expiryDate = expiry.toDate();
        final daysLeft = expiryDate.difference(now).inDays;

        if (daysLeft >= 0 && daysLeft <= 4) {
          count++;
        }
      }
    }

    return count;
  }

  int _lowStockCount(List<QueryDocumentSnapshot> docs) {
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final quantity = data['quantity'] ?? 0;

      if (quantity is num && quantity <= 2) {
        count++;
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Velora',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Later: open Notifications page
            },
            icon: const Icon(Icons.notifications_none_rounded, color: textDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No inventory data found.'));
          }

          final docs = snapshot.data!.docs;
          final totalItems = docs.length;
          final nearExpiry = _nearExpiryCount(docs);
          final lowStock = _lowStockCount(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeCard(),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Total Items',
                        value: totalItems.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Near Expiry',
                        value: nearExpiry.toString(),
                        icon: Icons.schedule_rounded,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Low Stock',
                        value: lowStock.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'AI Ready',
                        value: 'Smart',
                        icon: Icons.auto_awesome_rounded,
                        color: mint,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                _aiShortcutCard(),

                const SizedBox(height: 18),
                const RecentActivityCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purple, lightPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Food Inventory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track expiry, manage stock, and reduce food waste with AI help.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: textGrey,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiShortcutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: purple, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need recipe ideas?',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Use near-expiry items first with AI suggestions.',
                  style: TextStyle(color: textGrey, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
