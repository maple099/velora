import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey = 'PASTE_YOUR_GROQ_API_KEY_HERE';

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'llama-3.1-8b-instant';

  Future<Map<String, dynamic>> generateRecipes({
    required List<Map<String, dynamic>> inventoryItems,
  }) async {
    final usableItems = _getUsableItems(inventoryItems);

    if (usableItems.isEmpty) {
      return _fallbackNoSafeRecipe();
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': _systemPrompt()},
                {'role': 'user', 'content': _buildRecipePrompt(usableItems)},
              ],
              'temperature': 0.3,
              'max_tokens': 1200,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        return jsonDecode(content);
      }

      return _fallbackApiFailed(response.statusCode);
    } on TimeoutException {
      return _fallbackMessage(
        'Groq request timeout. Showing safe demo recipes.',
      );
    } catch (_) {
      return _fallbackMessage('Groq failed. Showing safe demo recipes.');
    }
  }

  List<Map<String, dynamic>> _getUsableItems(
    List<Map<String, dynamic>> inventoryItems,
  ) {
    final today = DateTime.now();

    final usableItems = inventoryItems.where((item) {
      final name = item['name']?.toString().trim() ?? '';
      final quantity = _toInt(item['quantity']);
      final expiryDate = _toDateTime(item['expiryDate']);

      if (name.isEmpty) return false;
      if (quantity <= 0) return false;
      if (expiryDate == null) return true;

      final expiryOnly = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      );

      final todayOnly = DateTime(today.year, today.month, today.day);

      return !expiryOnly.isBefore(todayOnly);
    }).toList();

    usableItems.sort((a, b) {
      final aDate = _toDateTime(a['expiryDate']);
      final bDate = _toDateTime(b['expiryDate']);

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });

    return usableItems;
  }

  String _systemPrompt() {
    return '''
You are Velora AI, a smart food inventory assistant.
You must return ONLY valid JSON.
Do not use markdown.
Do not add explanation outside JSON.
Generate only real existing recipes.
Never invent fake recipe names.
Use only safe, usable inventory ingredients.
Expired ingredients are already removed.
Prioritize near-expiry ingredients first.
Maximum 3 recipes only.
''';
  }

  String _buildRecipePrompt(List<Map<String, dynamic>> usableItems) {
    final inventoryText = usableItems.map((item) {
      final name = item['name'] ?? '';
      final quantity = _toInt(item['quantity']);
      final category = item['category'] ?? 'Unknown';
      final expiryDate = _toDateTime(item['expiryDate']);
      final daysLeft = _daysLeft(expiryDate);

      return {
        'name': name,
        'quantity': quantity,
        'category': category,
        'daysLeft': daysLeft,
      };
    }).toList();

    return '''
Generate recipe suggestions using this inventory:

${jsonEncode(inventoryText)}

Return JSON exactly in this structure:

{
  "status": "success",
  "message": "Generated recipe suggestions.",
  "recipes": [
    {
      "title": "Real recipe name",
      "ingredientsUsed": ["ingredient from inventory"],
      "missingIngredients": ["optional missing ingredient"],
      "steps": ["step 1", "step 2", "step 3"],
      "whyRecommended": "Explain how this recipe reduces food waste."
    }
  ]
}

Rules:
- Maximum 3 recipes.
- Use inventory ingredients only for ingredientsUsed.
- Missing ingredients must be small optional items only.
- Prioritize items with lowest daysLeft.
- Do not use expired items.
- Do not repeat recipe titles.
- Cooking steps must be clear and complete.
''';
  }

  Map<String, dynamic> _fallbackNoSafeRecipe() {
    return {
      'status': 'empty',
      'message': 'No safe usable ingredients available.',
      'recipes': [],
    };
  }

  Map<String, dynamic> _fallbackApiFailed(int statusCode) {
    return _fallbackMessage(
      'Groq API error $statusCode. Showing safe demo recipes.',
    );
  }

  Map<String, dynamic> _fallbackMessage(String message) {
    return {
      'status': 'fallback',
      'message': message,
      'recipes': [
        {
          'title': 'Simple Egg Fried Rice',
          'ingredientsUsed': ['Egg', 'Rice'],
          'missingIngredients': ['Salt', 'Cooking oil'],
          'steps': [
            'Heat a pan with a little cooking oil.',
            'Add cooked rice and stir for 2 minutes.',
            'Crack in the egg and mix until fully cooked.',
            'Season lightly with salt and serve warm.',
          ],
          'whyRecommended':
              'This fallback recipe is simple and helps use common basic ingredients safely.',
        },
      ],
    };
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    try {
      return value.toDate();
    } catch (_) {
      return null;
    }
  }

  int? _daysLeft(DateTime? expiryDate) {
    if (expiryDate == null) return null;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final expiryOnly = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );

    return expiryOnly.difference(todayOnly).inDays;
  }
}
