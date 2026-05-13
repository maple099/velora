import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/inventory_item.dart';
import '../utils_inventory/expiry_helper.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const InventoryCard({super.key, required this.item, required this.onTap});

  bool get hasImage => item.imageUrl.trim().isNotEmpty;

  IconData _icon(String category) {
    final value = category.toLowerCase();

    if (value.contains('dairy')) return Icons.local_drink_rounded;
    if (value.contains('meat')) return Icons.restaurant_rounded;
    if (value.contains('vegetable')) return Icons.eco_rounded;
    if (value.contains('fruit')) return Icons.apple_rounded;
    if (value.contains('grain')) return Icons.rice_bowl_rounded;

    return Icons.inventory_2_rounded;
  }

  Color _iconBg(String category) {
    final value = category.toLowerCase();

    if (value.contains('dairy')) return const Color(0xFFE0F2FE);
    if (value.contains('meat')) return const Color(0xFFFFEDD5);
    if (value.contains('vegetable')) return const Color(0xFFDCFCE7);
    if (value.contains('fruit')) return const Color(0xFFFEF3C7);
    if (value.contains('grain')) return const Color(0xFFF5F3FF);

    return const Color(0xFFF3E8FF);
  }

  Color _iconColor(String category) {
    final value = category.toLowerCase();

    if (value.contains('dairy')) return const Color(0xFF0284C7);
    if (value.contains('meat')) return const Color(0xFFF97316);
    if (value.contains('vegetable')) return const Color(0xFF16A34A);
    if (value.contains('fruit')) return const Color(0xFFF59E0B);
    if (value.contains('grain')) return const Color(0xFF7C3AED);

    return const Color(0xFF7C3AED);
  }

  Widget _imageOrIcon(bool isSmall) {
    final size = isSmall ? 58.0 : 66.0;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: _iconBg(item.category),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: hasImage
            ? kIsWeb
                  ? Icon(
                      _icon(item.category),
                      color: _iconColor(item.category),
                      size: isSmall ? 28 : 31,
                    )
                  : Image.file(
                      File(item.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        _icon(item.category),
                        color: _iconColor(item.category),
                        size: isSmall ? 28 : 31,
                      ),
                    )
            : Icon(
                _icon(item.category),
                color: _iconColor(item.category),
                size: isSmall ? 28 : 31,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 370;

    final expiryText = ExpiryHelper.daysLeftText(item.expiryDate);
    final expiryColor = ExpiryHelper.statusColor(item.expiryDate);
    final expiryBg = ExpiryHelper.statusBgColor(item.expiryDate);
    final isLowStock = item.quantity <= 3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isSmall ? 13 : 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _imageOrIcon(isSmall),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.category} • Qty: ${item.quantity}',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      color: isLowStock
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Expiry: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: expiryColor,
                    ),
                  ),
                  if (isLowStock) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Low Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              constraints: BoxConstraints(minWidth: isSmall ? 64 : 72),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: expiryBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                expiryText.contains('Expired')
                    ? 'Expired'
                    : expiryText.replaceAll(' left', '\nleft'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontWeight: FontWeight.w900,
                  color: expiryColor,
                ),
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
