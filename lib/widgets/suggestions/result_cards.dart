import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> recipes;
  final List<InventoryItem> inventoryItems;
  final void Function(Map<String, String> recipe) onCookNow;

  const ResultCards({
    super.key,
    required this.recipes,
    required this.inventoryItems,
    required this.onCookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recipes.map((recipe) {
        return _RecipeCard(
          recipe: recipe,
          inventoryItems: inventoryItems,
          onCookNow: onCookNow,
        );
      }).toList(),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, String> recipe;
  final List<InventoryItem> inventoryItems;
  final void Function(Map<String, String> recipe) onCookNow;

  const _RecipeCard({
    required this.recipe,
    required this.inventoryItems,
    required this.onCookNow,
  });

  List<InventoryItem> _matchedItems() {
    final text = '${recipe['title'] ?? ''} ${recipe['content'] ?? ''}'
        .toLowerCase();

    return inventoryItems.where((item) {
      final name = item.name.toLowerCase().trim();

      if (name.isEmpty) return false;
      if (item.quantity <= 0) return false;

      return text.contains(name);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? 'AI Suggestion';
    final content = recipe['content'] ?? '';
    final matchedItems = _matchedItems();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBox(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 14),
          if (matchedItems.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matchedItems.map((item) {
                return _IngredientChip(name: item.name);
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: matchedItems.isEmpty ? null : () => onCookNow(recipe),
              icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
              label: const Text(
                'Cook Now',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF9CA3AF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String name;

  const _IngredientChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7C3AED),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}
