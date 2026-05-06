import '../../../models/inventory_item.dart';

class FallbackRecipeBuilder {
  static Map<String, dynamic>? buildRecipe(List<InventoryItem> items) {
    final names = _inventoryNames(items).take(3).toList();

    if (names.isEmpty) return null;

    final title = '${_titleCase(names.take(2).join(' '))} Quick Stir Fry';

    return {
      'title': title,
      'content': _recipeContent(title, names),
      'ingredients': names,
      'steps': [
        'Wash and prepare the ingredients.',
        'Cut the ingredients into small pieces.',
        'Heat a pan with a little oil.',
        'Cook the ingredients for a few minutes.',
        'Serve while hot.',
      ],
      'nearExpiryIngredients': names,
      'whyRecommended':
          'This demo-safe recipe only uses items available in your inventory.',
    };
  }

  static String buildRestockText(List<InventoryItem> items) {
    final names = _inventoryNames(items);

    if (names.isEmpty) {
      return 'Add inventory items first to get restock suggestions.';
    }

    final shown = names.take(5).join(', ');

    return '''
Gemini quota limit reached. Showing demo-safe restock suggestions based on your inventory.

Restock Suggestions:
- Review your current stock: $shown.
- Restock items that are used often.
- Check quantity before buying more.
- Prioritize items needed for upcoming recipes.
- Avoid overbuying to reduce food waste.

This fallback does not use ingredients outside your inventory.
''';
  }

  static List<String> _inventoryNames(List<InventoryItem> items) {
    return items
        .map((item) => item.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  static String _recipeContent(String title, List<String> names) {
    return '''
$title

Ingredients:
${names.map((name) => '- $name').join('\n')}

Steps:
1. Wash and prepare the ingredients.
2. Cut the ingredients into small pieces.
3. Heat a pan with a little oil.
4. Cook the ingredients for a few minutes.
5. Serve while hot.

Why:
This recipe helps use available inventory items when Gemini quota is limited.
''';
  }

  static String _titleCase(String text) {
    return text
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
          final clean = word.trim();
          return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
