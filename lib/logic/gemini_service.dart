import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/inventory_item.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyALbpLBV0vCGIXnnyuLDGR_BUayMop91YI';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> generateRecipeSuggestions(List<InventoryItem> items) async {
    if (items.isEmpty) {
      return 'No inventory items found. Please add items first.';
    }

    final inventoryText = items
        .map((item) {
          final expiry = item.expiryDate.toIso8601String().split('T').first;
          return '- ${item.name}, quantity: ${item.quantity}, expiry: $expiry';
        })
        .join('\n');

    final prompt =
        """
You are a professional chef.

Generate EXACTLY 3 real, specific recipes using ONLY the available inventory items below.

IMPORTANT RULES:
- Use real, specific dish names.
- Do not use generic names like Quick Meal, Simple Dish, Mixed Meal, or Basic Recipe.
- Do not use markdown symbols like *, **, #, or backticks.
- Do not suggest ingredients that are not in the inventory list.
- Keep steps clear like a cooking tutorial.
- Each recipe must be realistic and easy to cook.

FORMAT EXACTLY LIKE THIS:

### Garlic Chicken Egg Stir Fry

Ingredients:
- Chicken
- Egg

Steps:
1. Cut the chicken into small pieces.
2. Beat the egg in a bowl.
3. Cook the chicken until fully done.
4. Add the egg and stir until cooked.
5. Serve while hot.

Why:
This recipe helps use Chicken and Egg before they expire.

Available inventory:
$inventoryText
""";

    return _sendPrompt(prompt);
  }

  Future<String> generateRestockRecommendations(
    List<InventoryItem> items,
  ) async {
    if (items.isEmpty) {
      return 'No inventory items found. Please add items first.';
    }

    final inventoryText = items
        .map((item) {
          final expiry = item.expiryDate.toIso8601String().split('T').first;
          return '- ${item.name}, quantity: ${item.quantity}, expiry: $expiry';
        })
        .join('\n');

    final prompt =
        """
You are an inventory assistant for a small F&B business.

Give smart restock recommendations based on the inventory below.

IMPORTANT RULES:
- Do not use markdown symbols like *, **, #, or backticks.
- Keep advice simple and practical.
- Mention low stock items.
- Mention items that may expire soon.
- Suggest what should be restocked first.

FORMAT:

### Restock Priority

Items to restock:
- item name: reason

Advice:
1. Clear advice
2. Clear advice
3. Clear advice

Inventory:
$inventoryText
""";

    return _sendPrompt(prompt);
  }

  Future<String> _sendPrompt(String prompt) async {
    try {
      final uri = Uri.parse('$_baseUrl?key=$_apiKey');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      debugPrint('GEMINI STATUS: ${response.statusCode}');
      debugPrint('GEMINI BODY: ${response.body}');

      if (response.statusCode == 429) {
        final seconds = _extractRetrySeconds(response.body);
        return 'Gemini quota limit reached. Please wait $seconds seconds before generating again.';
      }

      if (response.statusCode == 403) {
        return 'Gemini API key problem. Please check your API key.';
      }

      if (response.statusCode != 200) {
        return 'Gemini failed to generate. Please try again later.';
      }

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (text == null || text.toString().trim().isEmpty) {
        return 'No AI suggestion generated. Please try again.';
      }

      return _cleanText(text.toString());
    } catch (e) {
      debugPrint('GEMINI ERROR: $e');
      return 'Something went wrong while generating AI suggestion.';
    }
  }

  int _extractRetrySeconds(String body) {
    try {
      final data = jsonDecode(body);
      final details = data['error']?['details'];

      if (details is List) {
        for (final item in details) {
          final retryDelay = item['retryDelay'];
          if (retryDelay is String && retryDelay.endsWith('s')) {
            return int.tryParse(retryDelay.replaceAll('s', '')) ?? 60;
          }
        }
      }
    } catch (_) {}

    return 60;
  }

  String _cleanText(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('`', '')
        .trim();
  }
}
