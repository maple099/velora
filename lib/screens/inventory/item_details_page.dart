import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../services/activity_service.dart';
import 'edit_item_page.dart';
import 'utils_inventory/expiry_helper.dart';
import 'widgets_inventory/item_detail_action_button.dart';
import 'widgets_inventory/item_detail_info_card.dart';
import 'widgets_inventory/mark_as_used_dialog.dart';

class ItemDetailsPage extends StatelessWidget {
  final InventoryItem item;

  const ItemDetailsPage({super.key, required this.item});

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

  String _dateText(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(item.id)
        .delete();

    await ActivityService.addActivity(
      type: 'item_deleted',
      title: 'Deleted ${item.name}',
      subtitle: 'Item removed from inventory',
    );

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _markAsUsed(BuildContext context) async {
    final usedAmount = await showDialog<int>(
      context: context,
      builder: (_) => MarkAsUsedDialog(currentQuantity: item.quantity),
    );

    if (usedAmount == null) return;

    final newQuantity = item.quantity - usedAmount;

    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(item.id)
        .update({'quantity': newQuantity});

    await FirebaseFirestore.instance.collection('inventory_records').add({
      'itemId': item.id,
      'itemName': item.name,
      'type': 'stock_out',
      'quantity': usedAmount,
      'remainingQuantity': newQuantity,
      'createdAt': Timestamp.now(),
    });

    await ActivityService.addActivity(
      type: 'stock_out',
      title: '${item.name} marked as used',
      subtitle: 'Used $usedAmount, remaining $newQuantity',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  void _goToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditItemPage(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 370;

    final expiryText = ExpiryHelper.daysLeftText(item.expiryDate);
    final expiryColor = ExpiryHelper.statusColor(item.expiryDate);
    final expiryBg = ExpiryHelper.statusBgColor(item.expiryDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isSmall ? 16 : 22,
          8,
          isSmall ? 16 : 22,
          130,
        ),
        children: [
          _HeroSection(
            item: item,
            hasImage: hasImage,
            icon: _icon(item.category),
            iconBg: _iconBg(item.category),
            iconColor: _iconColor(item.category),
            expiryText: expiryText,
            expiryColor: expiryColor,
            expiryBg: expiryBg,
            isSmall: isSmall,
          ),
          const SizedBox(height: 18),
          ItemDetailInfoCard(
            rows: [
              ItemDetailInfoRow(
                label: 'Quantity',
                value: item.quantity.toString(),
              ),
              ItemDetailInfoRow(label: 'Category', value: item.category),
              ItemDetailInfoRow(
                label: 'Expiry Date',
                value: _dateText(item.expiryDate),
              ),
              ItemDetailInfoRow(
                label: 'Stored On',
                value: _dateText(item.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TipsCard(expiryText: expiryText, expiryColor: expiryColor),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          isSmall ? 16 : 22,
          8,
          isSmall ? 16 : 22,
          14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ItemDetailActionButton(
              label: 'Edit Item',
              icon: Icons.edit_rounded,
              color: const Color(0xFF7C3AED),
              onTap: () => _goToEdit(context),
            ),
            const SizedBox(height: 10),
            ItemDetailActionButton(
              label: 'Mark as Used',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              onTap: () => _markAsUsed(context),
            ),
            const SizedBox(height: 10),
            ItemDetailActionButton(
              label: 'Delete Item',
              icon: Icons.delete_rounded,
              color: const Color(0xFFEF4444),
              onTap: () => _deleteItem(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final InventoryItem item;
  final bool hasImage;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String expiryText;
  final Color expiryColor;
  final Color expiryBg;
  final bool isSmall;

  const _HeroSection({
    required this.item,
    required this.hasImage,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.expiryText,
    required this.expiryColor,
    required this.expiryBg,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _ImageBox(
            item: item,
            hasImage: hasImage,
            icon: icon,
            iconBg: iconBg,
            iconColor: iconColor,
            isSmall: isSmall,
          ),
          const SizedBox(height: 18),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 22 : 25,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.category,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: expiryBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              expiryText,
              style: TextStyle(fontWeight: FontWeight.w900, color: expiryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final InventoryItem item;
  final bool hasImage;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isSmall;

  const _ImageBox({
    required this.item,
    required this.hasImage,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final height = isSmall ? 150.0 : 180.0;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: hasImage && !kIsWeb
            ? Image.file(
                File(item.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Icon(icon, size: isSmall ? 58 : 70, color: iconColor);
  }
}

class _TipsCard extends StatelessWidget {
  final String expiryText;
  final Color expiryColor;

  const _TipsCard({required this.expiryText, required this.expiryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: This item status is $expiryText. Use near-expiry items first to reduce food waste.',
              style: TextStyle(
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: expiryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
