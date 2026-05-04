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

  bool get _isLowStock => item.quantity <= 3;

  Color _iconBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return const Color(0xFFE0F2FE);
      case 'vegetable':
        return const Color(0xFFE7F8EA);
      case 'fruit':
        return const Color(0xFFFEE2E2);
      case 'bakery':
        return const Color(0xFFFEF3C7);
      case 'meat':
        return const Color(0xFFFFEDD5);
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
        return const Color(0xFFD97706);
      case 'meat':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  Color _daysColor(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('expired') || lower.contains('today')) {
      return const Color(0xFFEF4444);
    }

    final number = int.tryParse(RegExp(r'\d+').stringMatch(text) ?? '');
    if (number == null) return const Color(0xFF7C3AED);
    if (number <= 3) return const Color(0xFFEF4444);
    if (number <= 7) return const Color(0xFFF59E0B);

    return const Color(0xFF7C3AED);
  }

  @override
  Widget build(BuildContext context) {
    final qtyColor = _isLowStock
        ? const Color(0xFFEF4444)
        : const Color(0xFF16A34A);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _categoryIcon(),
            const SizedBox(width: 14),
            Expanded(child: _itemInfo(qtyColor)),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6B7280),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _iconBgColor(item.category),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 30, color: _iconColor(item.category)),
    );
  }

  Widget _itemInfo(Color qtyColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            height: 1.1,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
            children: [
              TextSpan(text: '${item.category} • '),
              TextSpan(
                text: 'Qty: ${item.quantity}',
                style: TextStyle(color: qtyColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Expiry: $expiryText',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          daysLeftText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: _daysColor(daysLeftText),
          ),
        ),
        if (_isLowStock) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Low Stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
