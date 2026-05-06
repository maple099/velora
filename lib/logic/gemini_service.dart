import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/inventory_item.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAVlv3Aj3QwviSh_IdGNaPyRG4eF2VjKcA';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> generateRecipeSuggestions(List<InventoryItem> items) async {
    if (items.isEmpty) {
      return 'No inventory items found. Please add items first.';
    }

    final usableItems = items.where((item) => !_isExpired(item)).toList();

    if (usableItems.isEmpty) {
      return 'No safe recipe can be suggested because all inventory items are expired.';
    }

    final inventoryText = _buildInventoryText(usableItems);
    final nearExpiryText = _buildNearExpiryText(usableItems);
    final expiredText = _buildExpiredText(items);

    final prompt =
        """
You are Velora AI, a recipe assistant for an F&B inventory mobile app.

Your task:
Generate MAXIMUM 3 recipe suggestions using ONLY the usable inventory items below.

Usable inventory:
$inventoryText

Near-expiry items to prioritize:
$nearExpiryText

Expired items excluded:
$expiredText

VERY IMPORTANT RULES:
- Suggest maximum 3 recipes only.
- Use ONLY ingredients from the usable inventory list.
- Do NOT use expired items.
- Do NOT add ingredients that are not in usable inventory.
- Prioritize near-expiry items first.
- Each recipe must use at least 1 near-expiry item if possible.
- Do not use generic names like Quick Meal, Simple Dish, Mixed Meal, or Basic Recipe.
- Use real and specific dish names.
- Keep recipes simple and realistic for F&B stock usage.
- Keep output short to save API quota.
- Do not use markdown symbols like *, **, #, or backticks.

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
""";

    return _sendPrompt(prompt);
  }

  Future<String> generateRestockRecommendations(
    List<InventoryItem> items,
  ) async {
    if (items.isEmpty) {
      return 'No inventory items found. Please add items first.';
    }

    final usableItems = items.where((item) => !_isExpired(item)).toList();

    final inventoryText = _buildInventoryText(usableItems);
    final nearExpiryText = _buildNearExpiryText(usableItems);
    final expiredText = _buildExpiredText(items);

    final prompt =
        """
You are Velora AI, an inventory assistant for a small F&B business.

Give smart restock recommendations based on the inventory below.

Usable inventory:
$inventoryText

Near-expiry items:
$nearExpiryText

Expired items:
$expiredText

IMPORTANT RULES:
- Keep advice short and practical.
- Mention low stock usable items first.
- Mention near-expiry items that should be used soon.
- Mention expired items as items to remove or restock.
- Do not suggest using expired items in recipes.
- Do not use markdown symbols like *, **, #, or backticks.
- Keep output short to save API quota.

FORMAT EXACTLY LIKE THIS:

### Restock Priority

Items to restock:
- item name: short reason

Still need to use soon:
- item name: short reason

Expired stock to remove:
- item name: short reason

Advice:
1. Clear advice.
2. Clear advice.
3. Clear advice.
""";

    return _sendPrompt(prompt);
  }

  String _buildInventoryText(List<InventoryItem> items) {
    if (items.isEmpty) {
      return 'No usable inventory items found.';
    }

    return items
        .map((item) {
          final expiry = item.expiryDate.toIso8601String().split('T').first;
          final daysLeft = _daysLeft(item);

          return '- ${item.name}, quantity: ${item.quantity}, expiry: $expiry, days left: $daysLeft';
        })
        .join('\n');
  }

  String _buildNearExpiryText(List<InventoryItem> items) {
    final nearExpiry = items.where((item) {
      final daysLeft = _daysLeft(item);
      return daysLeft >= 0 && daysLeft <= 3;
    }).toList();

    if (nearExpiry.isEmpty) {
      return 'No near-expiry usable items found.';
    }

    return nearExpiry
        .map((item) {
          final expiry = item.expiryDate.toIso8601String().split('T').first;
          final daysLeft = _daysLeft(item);

          return '- ${item.name}, expiry: $expiry, days left: $daysLeft';
        })
        .join('\n');
  }

  String _buildExpiredText(List<InventoryItem> items) {
    final expired = items.where(_isExpired).toList();

    if (expired.isEmpty) {
      return 'No expired items found.';
    }

    return expired
        .map((item) {
          final expiry = item.expiryDate.toIso8601String().split('T').first;
          final daysLeft = _daysLeft(item);

          return '- ${item.name}, expiry: $expiry, days left: $daysLeft';
        })
        .join('\n');
  }

  int _daysLeft(InventoryItem item) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final expiryOnly = DateTime(
      item.expiryDate.year,
      item.expiryDate.month,
      item.expiryDate.day,
    );

    return expiryOnly.difference(todayOnly).inDays;
  }

  bool _isExpired(InventoryItem item) {
    return _daysLeft(item) < 0;
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
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 900},
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
