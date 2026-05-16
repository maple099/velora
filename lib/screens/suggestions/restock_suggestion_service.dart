import 'package:cloud_firestore/cloud_firestore.dart';

class RestockSuggestion {
  final String itemName;
  final String category;
  final String reason;
  final String suggestion;
  final int quantity;
  final int priority;
  final int? daysLeft;

  const RestockSuggestion({
    required this.itemName,
    required this.category,
    required this.reason,
    required this.suggestion,
    required this.quantity,
    required this.priority,
    this.daysLeft,
  });

  String get priorityLabel {
    if (priority == 1) return 'Urgent';
    if (priority == 2) return 'High';
    return 'Medium';
  }
}

class RestockSuggestionService {
  int _daysLeft(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  String _buildReason({
    required String name,
    required int quantity,
    required int? daysLeft,
  }) {
    if (quantity <= 0) {
      return '$name is out of stock and may stop cafe preparation.';
    }

    if (quantity <= 2) {
      return '$name is running low with only $quantity left.';
    }

    if (daysLeft != null && daysLeft >= 0 && daysLeft <= 1) {
      return '$name will expire very soon, so replacement stock should be prepared.';
    }

    return '$name may need restock soon based on current stock condition.';
  }

  String _buildSuggestion({required int quantity, required int? daysLeft}) {
    if (quantity <= 0) {
      return 'Restock immediately today.';
    }

    if (quantity <= 2) {
      return 'Restock within 1-2 days.';
    }

    if (daysLeft != null && daysLeft >= 0 && daysLeft <= 1) {
      return 'Prepare replacement stock before expiry.';
    }

    return 'Monitor stock and restock if usage increases.';
  }

  int _buildPriority({required int quantity, required int? daysLeft}) {
    if (quantity <= 0) return 1;
    if (quantity <= 2) return 2;
    if (daysLeft != null && daysLeft >= 0 && daysLeft <= 1) return 2;

    return 3;
  }

  List<RestockSuggestion> generateSuggestions(
    List<QueryDocumentSnapshot> docs,
  ) {
    final suggestions = <RestockSuggestion>[];
    final addedNames = <String>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? 'Item').toString().trim();
      final category = (data['category'] ?? 'General').toString().trim();
      final quantity = _toInt(data['quantity']);

      int? daysLeft;
      final expiryRaw = data['expiryDate'];

      if (expiryRaw is Timestamp) {
        daysLeft = _daysLeft(expiryRaw.toDate());
      }

      final shouldSuggest =
          quantity <= 2 || (daysLeft != null && daysLeft >= 0 && daysLeft <= 1);

      if (!shouldSuggest || addedNames.contains(name.toLowerCase())) {
        continue;
      }

      addedNames.add(name.toLowerCase());

      suggestions.add(
        RestockSuggestion(
          itemName: name,
          category: category,
          quantity: quantity,
          daysLeft: daysLeft,
          priority: _buildPriority(quantity: quantity, daysLeft: daysLeft),
          reason: _buildReason(
            name: name,
            quantity: quantity,
            daysLeft: daysLeft,
          ),
          suggestion: _buildSuggestion(quantity: quantity, daysLeft: daysLeft),
        ),
      );
    }

    suggestions.sort((a, b) {
      final priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) return priorityCompare;

      return a.quantity.compareTo(b.quantity);
    });

    return suggestions.take(5).toList();
  }
}
