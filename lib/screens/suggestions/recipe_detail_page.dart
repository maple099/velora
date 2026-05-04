import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';
import '../../widgets/suggestions/cook_now_sheet.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, String> recipe;
  final List<InventoryItem> matchedItems;
  final Future<void> Function(List<InventoryItem>) onCook;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.matchedItems,
    required this.onCook,
  });

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? 'Recipe Detail';
    final content = recipe['content'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(title: title),
              const SizedBox(height: 18),
              _HeroCard(title: title),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Recipe Tutorial',
                icon: Icons.menu_book_rounded,
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Ingredients from Inventory',
                icon: Icons.inventory_2_rounded,
                child: matchedItems.isEmpty
                    ? const Text(
                        'No matching inventory ingredients found.',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Column(
                        children: matchedItems
                            .map((item) => _IngredientTile(item: item))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: matchedItems.isEmpty
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return CookNowSheet(
                                recipeTitle: title,
                                matchedItems: matchedItems,
                                onConfirm: () async {
                                  Navigator.pop(context);
                                  await onCook(matchedItems);
                                  if (context.mounted) Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                  icon: const Icon(Icons.restaurant_menu_rounded),
                  label: const Text(
                    'Cook Now',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;

  const _HeroCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icon(icon, color: const Color(0xFF7C3AED), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final InventoryItem item;

  const _IngredientTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.expiryDate.difference(DateTime.now()).inDays;
    final isNear = days <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isNear ? const Color(0xFFFFF7ED) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNear ? const Color(0xFFFED7AA) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNear ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: isNear ? const Color(0xFFF97316) : const Color(0xFF10B981),
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Text(
            isNear ? 'Near expiry' : 'Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isNear ? const Color(0xFFF97316) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
