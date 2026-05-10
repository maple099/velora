import 'package:cloud_firestore/cloud_firestore.dart';

class RestockSuggestion {
  final String itemName;
  final String reason;
  final int priority;

  const RestockSuggestion({
    required this.itemName,
    required this.reason,
    required this.priority,
  });
}

class RestockSuggestionService {
  int _daysLeft(DateTime expiryDate) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  List<RestockSuggestion> generateSuggestions(
    List<QueryDocumentSnapshot> docs,
  ) {
    final suggestions = <RestockSuggestion>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? 'Item').toString();
      final quantity = data['quantity'] ?? 0;

      if (quantity <= 0) {
        suggestions.add(
          RestockSuggestion(
            itemName: name,
            reason: 'Out of stock. Restock immediately.',
            priority: 1,
          ),
        );
      } else if (quantity <= 2) {
        suggestions.add(
          RestockSuggestion(
            itemName: name,
            reason: 'Running low. Consider buying soon.',
            priority: 2,
          ),
        );
      }

      final expiryRaw = data['expiryDate'];

      if (expiryRaw is Timestamp) {
        final days = _daysLeft(expiryRaw.toDate());

        if (days >= 0 && days <= 1) {
          suggestions.add(
            RestockSuggestion(
              itemName: name,
              reason: 'Expires very soon. Prepare replacement stock.',
              priority: 2,
            ),
          );
        }
      }
    }

    suggestions.sort((a, b) => a.priority.compareTo(b.priority));

    return suggestions;
  }
}
