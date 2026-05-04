import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/inventory_item.dart';

class GeminiService {
  GeminiService();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  GenerativeModel _model() {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is missing.');
    }

    return GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> generateRecipeSuggestions(List<InventoryItem> items) async {
    if (items.isEmpty) {
      return 'No inventory items found. Add some items first to get AI suggestions.';
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

Based on these inventory items, suggest simple recipes that can reduce food waste.

Rules:
- Focus on items that expire soon.
- Use simple student-friendly English.
- Give 3 recipe suggestions.
- For each recipe, include:
  1. Recipe name
  2. Ingredients to use
  3. Simple steps
  4. Why this helps reduce waste

Inventory items:
$itemText
''';

    try {
      final response = await _model().generateContent([Content.text(prompt)]);

      return response.text ?? 'No suggestion generated. Please try again.';
    } catch (e) {
      return 'Gemini failed to generate suggestions. Please check your internet connection or API key.';
    }
  }

  Future<String> generateRestockRecommendations(
    List<InventoryItem> items,
  ) async {
    if (items.isEmpty) {
      return 'No inventory items found. Add some items first to get restock recommendations.';
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

Based on the inventory below, suggest smart restock recommendations.

Rules:
- Recommend items with low quantity.
- Do not recommend too much stock if expiry is soon.
- Use simple student-friendly English.
- Give short and clear recommendations.
- Format the answer nicely for a mobile app.

Inventory items:
$itemText
''';

    try {
      final response = await _model().generateContent([Content.text(prompt)]);

      return response.text ?? 'No recommendation generated. Please try again.';
    } catch (e) {
      return 'Gemini failed to generate recommendations. Please check your internet connection or API key.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
