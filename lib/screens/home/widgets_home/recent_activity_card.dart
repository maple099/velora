import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  String _formatType(String type) {
    switch (type) {
      case 'stock_in':
        return 'Stock In';
      case 'stock_out':
        return 'Stock Out';
      case 'add_item':
        return 'Item Added';
      default:
        return 'Activity';
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'stock_in':
      case 'add_item':
        return Icons.add_circle_rounded;
      case 'stock_out':
        return Icons.remove_circle_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'stock_in':
      case 'add_item':
        return const Color(0xFF10B981);
      case 'stock_out':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  String _timeAgo(dynamic rawTime) {
    if (rawTime is! Timestamp) return 'Recently';

    final time = rawTime.toDate();
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour ago';
    return '${diff.inDays} day ago';
  }

  String _message(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString();
    final itemName = (data['itemName'] ?? data['name'] ?? 'Item').toString();
    final quantity = data['quantity'] ?? data['usedQuantity'] ?? '';

    if (type == 'stock_in' || type == 'add_item') {
      return '$itemName added to inventory';
    }

    if (type == 'stock_out') {
      return '$itemName used from inventory${quantity == '' ? '' : ' • $quantity used'}';
    }

    return '$itemName updated';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inventory_records')
            .orderBy('createdAt', descending: true)
            .limit(4)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _RecentActivityError();
          }

          if (!snapshot.hasData) {
            return const SizedBox(
              height: 90,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const _RecentActivityEmpty();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final type = (data['type'] ?? '').toString();

                return _ActivityTile(
                  icon: _icon(type),
                  color: _color(type),
                  title: _formatType(type),
                  message: _message(data),
                  time: _timeAgo(data['createdAt']),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityEmpty extends StatelessWidget {
  const _RecentActivityEmpty();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'No stock activity yet.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentActivityError extends StatelessWidget {
  const _RecentActivityError();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Recent activity cannot load right now.',
      style: TextStyle(
        color: Color(0xFFEF4444),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
