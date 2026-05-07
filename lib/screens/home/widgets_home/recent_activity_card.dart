import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeRecentActivityCard extends StatelessWidget {
  const HomeRecentActivityCard({super.key});

  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('inventory_records')
                .orderBy('createdAt', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Text(
                  'No recent activity yet.',
                  style: TextStyle(color: textGrey, fontSize: 13),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final itemName = (data['itemName'] ?? 'Unknown Item')
                      .toString();
                  final type = (data['type'] ?? '').toString();
                  final quantity = data['quantity'] ?? 0;

                  return _activityTile(
                    title: _title(type, itemName),
                    subtitle: 'Quantity: $quantity',
                    icon: _icon(type),
                    iconColor: _iconColor(type),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _title(String type, String itemName) {
    if (type == 'stock_in') return '$itemName added';
    if (type == 'stock_out') return '$itemName used';
    return itemName;
  }

  IconData _icon(String type) {
    if (type == 'stock_in') return Icons.add_circle_outline_rounded;
    if (type == 'stock_out') return Icons.remove_circle_outline_rounded;
    return Icons.history_rounded;
  }

  Color _iconColor(String type) {
    if (type == 'stock_in') return const Color(0xFF10B981);
    if (type == 'stock_out') return Colors.orange;
    return purple;
  }

  Widget _activityTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
