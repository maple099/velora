import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';

class NearExpiryCard extends StatelessWidget {
  final InventoryItem item;
  final String daysLeft;

  const NearExpiryCard({super.key, required this.item, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            color: Color(0xFFF97316),
            size: 18,
          ),

          const SizedBox(height: 6),

          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),

          Text(
            item.category,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),

          Text(
            'Qty: ${item.quantity}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysLeft,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
