import 'package:flutter/material.dart';

import '../../../models/inventory_item.dart';
import '../item_details_page.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final IconData icon;
  final String expiryText;
  final String daysLeftText;

  const InventoryCard({
    super.key,
    required this.item,
    required this.icon,
    required this.expiryText,
    required this.daysLeftText,
  });

  Color _iconBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return const Color(0xFFE0F2FE);
      case 'vegetable':
        return const Color(0xFFDCFCE7);
      case 'fruit':
        return const Color(0xFFFEE2E2);
      case 'bakery':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF3E8FF);
    }
  }

  Color _iconColor(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return const Color(0xFF0284C7);
      case 'vegetable':
        return const Color(0xFF16A34A);
      case 'fruit':
        return const Color(0xFFDC2626);
      case 'bakery':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item)),
        );
      },
      child: Container(
        // ❌ NO FIXED HEIGHT (IMPORTANT FIX)
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _iconBgColor(item.category),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: _iconColor(item.category)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.category} • Qty: ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Expiry: $expiryText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysLeftText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}
