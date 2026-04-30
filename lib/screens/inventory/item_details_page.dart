import 'package:flutter/material.dart';

import '../../logic/firestore_service.dart';
import '../../models/inventory_item.dart';

class ItemDetailsPage extends StatelessWidget {
  final InventoryItem item;

  const ItemDetailsPage({super.key, required this.item});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return Icons.restaurant_rounded;
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'vegetable':
        return Icons.eco_rounded;
      case 'fruit':
        return Icons.apple_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Future<void> _showStockOutDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mark as Used'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity used',
              hintText: 'Current stock: ${item.quantity}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(controller.text.trim()) ?? 0;

                if (qty <= 0 || qty > item.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid quantity')),
                  );
                  return;
                }

                await FirestoreService.instance.markStockOut(
                  item: item,
                  usedQuantity: qty,
                );

                if (!context.mounted) return;

                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _deleteItem(BuildContext context) async {
    await FirestoreService.instance.deleteItem(item.id);

    if (!context.mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 24),
              _itemImage(),
              const SizedBox(height: 24),
              _itemTitle(),
              const SizedBox(height: 20),
              _detailsCard(),
              const Spacer(),
              _markUsedButton(context),
              const SizedBox(height: 10),
              _deleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _itemImage() {
    return Center(
      child: Container(
        width: 125,
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Icon(
          _iconForCategory(item.category),
          size: 62,
          color: const Color(0xFF7C3AED),
        ),
      ),
    );
  }

  Widget _itemTitle() {
    return Center(
      child: Column(
        children: [
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.category,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _detailRow('Quantity', item.quantity.toString()),
          _divider(),
          _detailRow('Expiry Date', _formatDate(item.expiryDate)),
          _divider(),
          _detailRow('Created At', _formatDate(item.createdAt)),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFE5E7EB),
    );
  }

  Widget _markUsedButton(BuildContext context) {
    return _actionButton(
      text: 'Mark as Used',
      colors: const [Color(0xFF10B981), Color(0xFF34D399)],
      onTap: () => _showStockOutDialog(context),
    );
  }

  Widget _deleteButton(BuildContext context) {
    return _actionButton(
      text: 'Delete Item',
      colors: const [Color(0xFFEF4444), Color(0xFFF87171)],
      onTap: () => _deleteItem(context),
    );
  }

  Widget _actionButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
