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
      return _fallbackRecipes();
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

Based on these inventory items, suggest recipe ideas that reduce food waste.

IMPORTANT RULES:
- Give between 1 to 6 recipe suggestions.
- Focus on near-expiry items first.
- Use simple student-friendly English.
- Each recipe MUST start with this format:
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
        return _fallbackRecipes();
      }

      return text;
    } catch (_) {
      return _fallbackRecipes();
    }
  }

  Future<String> generateRestockRecommendations(
    List<InventoryItem> items,
  ) async {
    if (items.isEmpty) {
      return _fallbackRestock();
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
        return _fallbackRestock();
      }

      return text;
    } catch (_) {
      return _fallbackRestock();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _fallbackRecipes() {
    return '''
### Tomato Egg Toast

**Ingredients to use:**
- Bread
- Egg
- Tomato

**Simple steps:**
1. Toast the bread until slightly crispy.
2. Cook the egg in a pan.
3. Add tomato slices on top of the toast.
4. Serve while warm.

**Why this helps reduce waste:**
This recipe helps use bread, egg, and tomato before they expire.


### Chicken Egg Fried Rice

**Ingredients to use:**
- Chicken
- Egg
- Rice
- Onion

**Simple steps:**
1. Cut the chicken into small pieces.
2. Cook the chicken in a pan.
3. Add rice and egg.
4. Mix everything until cooked.

**Why this helps reduce waste:**
This recipe uses leftover rice, chicken, and egg in one simple meal.


### Bread Pudding

**Ingredients to use:**
- Bread
- Milk
- Egg

**Simple steps:**
1. Cut bread into small pieces.
2. Mix milk and egg together.
3. Pour the mixture over the bread.
4. Bake or steam until soft.

**Why this helps reduce waste:**
This recipe is useful when bread is near expiry.
''';
  }

  String _fallbackRestock() {
    return '''
### Smart Restock Advice

**Items to check:**
- Rice
- Milk
- Egg
- Chicken

**Simple recommendation:**
1. Restock items with low quantity first.
2. Avoid buying too much food that expires quickly.
3. Buy dry food in larger amounts because it lasts longer.
4. Buy fresh food in smaller amounts to reduce waste.

**Why this helps:**
This helps keep enough stock while avoiding expired food.
''';
  }
}
