import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../screens/suggestions/recipe_detail_page.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> recipes;
  final List<InventoryItem> inventoryItems;
  final Future<void> Function(List<InventoryItem>) onCookRecipe;

  const ResultCards({
    super.key,
    required this.recipes,
    required this.inventoryItems,
    required this.onCookRecipe,
  });

  List<InventoryItem> _matchedItems(Map<String, String> recipe) {
    final text = '${recipe['title'] ?? ''} ${recipe['content'] ?? ''}'
        .toLowerCase();

    return inventoryItems.where((item) {
      final name = item.name.toLowerCase().trim();
      if (name.isEmpty || item.quantity <= 0) return false;
      return text.contains(name);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recipes.map((recipe) {
        final matched = _matchedItems(recipe);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      recipe['title'] ?? 'AI Suggestion',
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
                recipe['content'] ?? '',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 14),
              if (matched.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matched.map((item) {
                    return _IngredientChip(name: item.name);
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(
                          recipe: recipe,
                          matchedItems: matched,
                          onCook: onCookRecipe,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text(
                    'View Recipe',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
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
      }).toList(),
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
