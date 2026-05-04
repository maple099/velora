import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/inventory_item.dart';

class GeminiService {
  GeminiService();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  GenerativeModel _model() {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is empty.');
    }

    return GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
  }

  Future<String> generateRecipeSuggestions(List<InventoryItem> items) async {
    if (items.isEmpty) {
      return _emptyRecipeMessage();
    }

    final itemText = items
        .map((item) {
          return '''
Name: ${item.name}
Category: ${item.category}
Quantity: ${item.quantity}
Expiry Date: ${_formatDate(item.expiryDate)}
''';
        })
        .join('\n');

    final prompt =
        '''
You are an AI assistant for Velora, a smart F&B inventory mobile app.

Suggest recipe ideas that reduce food waste.

IMPORTANT RULES:
- Give between 1 to 6 recipe suggestions.
- Use ONLY ingredients from the inventory list.
- Do NOT add ingredients that are not in the inventory.
- Focus on near-expiry items first.
- Use simple student-friendly English.
- Each recipe MUST start with:
### Recipe Name

For each recipe, include:
**Ingredients to use:**
- ingredient name

**Simple steps:**
1. step one
2. step two
3. step three

**Why this helps reduce waste:**
Short explanation.

Inventory items:
$itemText
''';

    try {
      final response = await _model().generateContent([Content.text(prompt)]);

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        return _smartFallbackRecipes(items);
      }

      return text;
    } catch (_) {
      return _smartFallbackRecipes(items);
    }
  }

  Future<String> generateRestockRecommendations(
    List<InventoryItem> items,
  ) async {
    if (items.isEmpty) {
      return _emptyRestockMessage();
    }

    final itemText = items
        .map((item) {
          return '''
Name: ${item.name}
Category: ${item.category}
Quantity: ${item.quantity}
Expiry Date: ${_formatDate(item.expiryDate)}
''';
        })
        .join('\n');

    final prompt =
        '''
You are an AI assistant for Velora.

Suggest smart restock recommendations based on this inventory.

Rules:
- Recommend low quantity items.
- Do not recommend too much stock if expiry is soon.
- Use simple student-friendly English.
- Use bullet points.
- Keep it short and mobile-friendly.

Inventory items:
$itemText
''';

    try {
      final response = await _model().generateContent([Content.text(prompt)]);

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        return _smartFallbackRestock(items);
      }

      return text;
    } catch (_) {
      return _smartFallbackRestock(items);
    }
  }

  String _smartFallbackRecipes(List<InventoryItem> items) {
    final availableItems = items.where((item) => item.quantity > 0).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    if (availableItems.isEmpty) {
      return _emptyRecipeMessage();
    }

    final recipeCount = availableItems.length.clamp(1, 6);
    final selectedItems = availableItems.take(recipeCount).toList();

    final recipes = selectedItems
        .map((mainItem) {
          final helperItems = availableItems
              .where((item) => item.id != mainItem.id)
              .take(2)
              .toList();

          final ingredients = [mainItem, ...helperItems];

          final recipeName = _recipeName(mainItem, helperItems);

          final ingredientText = ingredients
              .map((item) => '- ${_capitalize(item.name)}')
              .join('\n');

          return '''
### $recipeName

**Ingredients to use:**
$ingredientText

**Simple steps:**
1. Prepare ${ingredients.map((item) => item.name).join(', ')}.
2. Cook or combine the ingredients in a simple way.
3. Serve while fresh.

**Why this helps reduce waste:**
This recipe helps use ${_capitalize(mainItem.name)} before it expires.
''';
        })
        .join('\n\n');

    return recipes;
  }

  String _smartFallbackRestock(List<InventoryItem> items) {
    final lowItems = items.where((item) => item.quantity <= 2).toList();

    if (lowItems.isEmpty) {
      return '''
### Smart Restock Advice

**Items to check:**
- Your current stock looks enough for now.

**Simple recommendation:**
1. No urgent restock is needed.
2. Use near-expiry items first.
3. Check inventory again after stock decreases.

**Why this helps:**
This helps avoid overbuying and reduces food waste.
''';
    }

    final itemText = lowItems
        .map((item) {
          return '- ${_capitalize(item.name)} | Qty: ${item.quantity}';
        })
        .join('\n');

    return '''
### Smart Restock Advice

**Items to check:**
$itemText

**Simple recommendation:**
1. Restock low quantity items first.
2. Buy fresh food in small amounts.
3. Avoid overstocking items that expire quickly.

**Why this helps:**
This helps keep enough stock while reducing expired food.
''';
  }

  String _recipeName(InventoryItem mainItem, List<InventoryItem> helperItems) {
    final mainName = _capitalize(mainItem.name);

    if (helperItems.isEmpty) {
      return 'Simple $mainName Recipe';
    }

    final secondName = _capitalize(helperItems.first.name);

    final category = mainItem.category.toLowerCase();

    if (category.contains('bakery')) return '$mainName with $secondName';
    if (category.contains('meat')) return '$mainName Quick Meal';
    if (category.contains('dairy')) return '$mainName Mix Bowl';
    if (category.contains('vegetable')) return '$mainName Fresh Dish';

    return '$mainName and $secondName Recipe';
  }

  String _emptyRecipeMessage() {
    return '''
### No Recipe Available

**Ingredients to use:**
- No available inventory items

**Simple steps:**
1. Add inventory items first.
2. Set quantity and expiry date.
3. Generate recipe suggestions again.

**Why this helps reduce waste:**
Velora needs your inventory data to suggest useful recipes.
''';
  }

  String _emptyRestockMessage() {
    return '''
### No Restock Data Available

**Items to check:**
- No inventory items found

**Simple recommendation:**
1. Add items into inventory first.
2. Track quantity and expiry date.
3. Generate restock advice again.

**Why this helps:**
Velora needs inventory data to give better restock suggestions.
''';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
