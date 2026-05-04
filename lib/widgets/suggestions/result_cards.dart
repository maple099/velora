import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../screens/suggestions/recipe_detail_page.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> results;
  final List<InventoryItem> inventoryItems;
  final bool isRecipeResult;
  final Future<void> Function(List<InventoryItem>)? onCookRecipe;

  const ResultCards({
    super.key,
    required this.results,
    required this.inventoryItems,
    required this.isRecipeResult,
    required this.onCookRecipe,
  });

  List<InventoryItem> _matchedItems(Map<String, String> result) {
    final text = '${result['title'] ?? ''} ${result['content'] ?? ''}'
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
      children: results.map((result) {
        final matched = _matchedItems(result);

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
                  _IconBox(isRecipe: isRecipeResult),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['title'] ?? 'AI Suggestion',
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
                result['content'] ?? '',
                maxLines: isRecipeResult ? 5 : null,
                overflow: isRecipeResult
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 14),

              if (isRecipeResult && matched.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matched.map((item) {
                    return _IngredientChip(name: item.name);
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              if (isRecipeResult)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (onCookRecipe == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(
                            recipe: result,
                            matchedItems: matched,
                            onCook: onCookRecipe!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text(
                      'View Recipe',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
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
  final bool isRecipe;

  const _IconBox({required this.isRecipe});

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
      child: Icon(
        isRecipe
            ? Icons.auto_awesome_rounded
            : Icons.shopping_cart_checkout_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}
