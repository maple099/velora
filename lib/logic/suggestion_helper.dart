import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';

class SuggestionHelper {
  List<InventoryItem> convertDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return InventoryItem(
        id: doc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        quantity: (data['quantity'] as num?)?.toInt() ?? 0,
        expiryDate: data['expiryDate'] is Timestamp
            ? (data['expiryDate'] as Timestamp).toDate()
            : DateTime.now(),
        imageUrl: data['imageUrl'] ?? '',
        createdAt: data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
  }

  List<InventoryItem> nearExpiryItems(List<InventoryItem> items) {
    final now = DateTime.now();

    final filtered = items.where((item) {
      final daysLeft = item.expiryDate.difference(now).inDays;
      return daysLeft <= 7;
    }).toList();

    filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return filtered.take(4).toList();
  }

  List<Map<String, String>> parseRecipes(String text) {
    final recipes = <Map<String, String>>[];
    final parts = text.split('###');

    for (final part in parts) {
      final clean = part.trim();
      if (clean.isEmpty) continue;

      final lines = clean.split('\n');

      recipes.add({
        'title': lines.first.trim(),
        'content': lines.skip(1).join('\n').trim(),
      });
    }

    if (recipes.isEmpty && text.trim().isNotEmpty) {
      recipes.add({'title': 'AI Suggestion', 'content': text});
    }

    return recipes;
  }

  List<InventoryItem> matchedIngredients(
    Map<String, String> recipe,
    List<InventoryItem> items,
  ) {
    final recipeText = '${recipe['title'] ?? ''} ${recipe['content'] ?? ''}'
        .toLowerCase();

    return items.where((item) {
      final name = item.name.toLowerCase().trim();

      if (name.isEmpty) return false;
      if (item.quantity <= 0) return false;

      return recipeText.contains(name);
    }).toList();
  }

  String daysLeftText(DateTime expiryDate) {
    final days = expiryDate.difference(DateTime.now()).inDays;

    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }
}
