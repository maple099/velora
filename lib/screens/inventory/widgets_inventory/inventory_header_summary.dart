import 'package:flutter/material.dart';

class InventoryHeaderSummary extends StatelessWidget {
  final int totalItems;
  final int visibleItems;
  final bool isSmallPhone;

  const InventoryHeaderSummary({
    super.key,
    required this.totalItems,
    required this.visibleItems,
    required this.isSmallPhone,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = totalItems == visibleItems
        ? '$totalItems items in your inventory'
        : '$visibleItems of $totalItems items shown';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: isSmallPhone ? 46 : 50,
            width: isSmallPhone ? 46 : 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track your stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 15 : 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: isSmallPhone ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_graph_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
