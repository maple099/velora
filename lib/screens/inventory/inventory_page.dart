import 'package:flutter/material.dart';

import '../../logic/firestore_service.dart';
import '../../models/inventory_item.dart';
import 'item_details_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String selectedFilter = 'All Items';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    final query = searchController.text.toLowerCase().trim();

    return items.where((item) {
      final matchSearch =
          _matchesPrefix(item.name, query) ||
          _matchesPrefix(item.category, query);

      if (selectedFilter == 'All Items') return matchSearch;

      if (selectedFilter == 'Low Stock') {
        return matchSearch && item.quantity <= 2;
      }

      if (selectedFilter == 'Near Expiry') {
        final daysLeft = item.expiryDate.difference(DateTime.now()).inDays;
        return matchSearch && daysLeft <= 3 && daysLeft >= 0;
      }

      return matchSearch;
    }).toList();
  }

  bool _matchesPrefix(String text, String query) {
    if (query.isEmpty) return true;

    final normalized = text.toLowerCase().trim();

    if (normalized.startsWith(query)) return true;

    final words = normalized.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.startsWith(query)) return true;
    }

    return false;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 22),
              _searchBar(),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 16),

              StreamBuilder<List<InventoryItem>>(
                stream: FirestoreService.instance.getItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Something went wrong')),
                    );
                  }

                  final items = snapshot.data ?? [];
                  final filteredItems = _filterItems(items);

                  if (filteredItems.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredItems.map((item) {
                      return _InventoryCard(
                        item: item,
                        icon: _iconForCategory(item.category),
                        expiryText: _formatDate(item.expiryDate),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Row(
      children: [
        Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Color(0xFF111827),
        ),
        SizedBox(width: 18),
        Text(
          'Inventory',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 21,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune_rounded, color: Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _filters() {
    final filters = ['All Items', 'Low Stock', 'Near Expiry'];

    return Row(
      children: filters.map((filter) {
        final isActive = selectedFilter == filter;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF7C3AED) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final IconData icon;
  final String expiryText;

  const _InventoryCard({
    required this.item,
    required this.icon,
    required this.expiryText,
  });

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
        height: 92,
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: const Color(0xFF7C3AED)),
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
                  const SizedBox(height: 5),
                  Text(
                    'Expiry: $expiryText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
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
