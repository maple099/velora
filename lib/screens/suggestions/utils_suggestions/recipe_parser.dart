import '../../../models/inventory_item.dart';

class RecipeParser {
  static String title(Map<String, String> recipe) {
    return recipe['title']?.trim().isNotEmpty == true
        ? recipe['title']!.trim()
        : 'AI Recipe';
  }

  static String content(Map<String, String> recipe) {
    return recipe['content'] ?? '';
  }

  static List<String> nearExpiryNames(List<InventoryItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return items
        .where((item) {
          final expiry = DateTime(
            item.expiryDate.year,
            item.expiryDate.month,
            item.expiryDate.day,
          );

          final days = expiry.difference(today).inDays;
          return days >= 0 && days <= 3;
        })
        .map((item) {
          return item.name.trim();
        })
        .where((name) {
          return name.isNotEmpty;
        })
        .toList();
  }

  static List<String> ingredients(String content) {
    final lines = content.split('\n');
    final result = <String>[];
    var reading = false;

    for (final line in lines) {
      final clean = line.trim();
      final lower = clean.toLowerCase();

      if (lower.startsWith('ingredients')) {
        reading = true;
        continue;
      }

      if (lower.startsWith('steps')) break;

      if (reading && clean.startsWith('-')) {
        result.add(clean.replaceFirst('-', '').trim());
      }
    }

    return result.isEmpty ? ['Inventory ingredients'] : result;
  }

  static List<String> steps(String content) {
    final lines = content.split('\n');
    final result = <String>[];
    var reading = false;

    for (final line in lines) {
      final clean = line.trim();
      final lower = clean.toLowerCase();

      if (lower.startsWith('steps')) {
        reading = true;
        continue;
      }

      if (lower.startsWith('why')) break;

      if (reading && RegExp(r'^\d+\.').hasMatch(clean)) {
        result.add(clean.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim());
      }
    }

    return result.isEmpty
        ? ['Follow the AI suggestion shown in the recipe card.']
        : result;
  }

  static String why(String content) {
    final lines = content.split('\n');
    final result = <String>[];
    var reading = false;

    for (final line in lines) {
      final clean = line.trim();

      if (clean.toLowerCase().startsWith('why')) {
        reading = true;
        final afterColon = clean.split(':').skip(1).join(':').trim();
        if (afterColon.isNotEmpty) result.add(afterColon);
        continue;
      }

      if (reading && clean.isNotEmpty) result.add(clean);
    }

    return result.isEmpty
        ? 'This recipe helps use available inventory items and reduce food waste.'
        : result.join(' ');
  }
}
