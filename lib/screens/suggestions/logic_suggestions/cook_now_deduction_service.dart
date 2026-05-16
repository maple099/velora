import 'package:cloud_firestore/cloud_firestore.dart';

class CookNowDeductionResult {
  final bool success;
  final String message;
  final List<String> usedItems;
  final List<String> skippedItems;

  const CookNowDeductionResult({
    required this.success,
    required this.message,
    required this.usedItems,
    required this.skippedItems,
  });
}

class CookNowDeductionService {
  final FirebaseFirestore _firestore;

  CookNowDeductionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<CookNowDeductionResult> deductRecipeIngredients({
    required String userId,
    required String recipeTitle,
    required List<String> ingredients,
  }) async {
    try {
      if (userId.trim().isEmpty) {
        return const CookNowDeductionResult(
          success: false,
          message: 'User is not logged in.',
          usedItems: [],
          skippedItems: [],
        );
      }

      if (ingredients.isEmpty) {
        return const CookNowDeductionResult(
          success: false,
          message: 'No recipe ingredients found.',
          usedItems: [],
          skippedItems: [],
        );
      }

      final inventoryRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory');

      final snapshot = await inventoryRef.get();

      final usedItems = <String>[];
      final skippedItems = <String>[];

      final normalizedIngredients = ingredients
          .map(_cleanName)
          .where((name) => name.isNotEmpty)
          .toList();

      for (final ingredient in normalizedIngredients) {
        final matchedDoc = _findMatchingInventoryDoc(
          ingredient: ingredient,
          docs: snapshot.docs,
        );

        if (matchedDoc == null) {
          skippedItems.add('$ingredient not found');
          continue;
        }

        final data = matchedDoc.data();

        final name = (data['name'] ?? ingredient).toString();
        final quantity = _toInt(data['quantity']);
        final expiryDate = _toDateTime(data['expiryDate']);

        if (quantity <= 0) {
          skippedItems.add('$name has no stock');
          continue;
        }

        if (expiryDate != null && _isExpired(expiryDate)) {
          skippedItems.add('$name is expired');
          continue;
        }

        await matchedDoc.reference.update({
          'quantity': quantity - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _saveActivity(
          userId: userId,
          itemName: name,
          recipeTitle: recipeTitle,
        );

        usedItems.add(name);
      }

      if (usedItems.isEmpty) {
        return CookNowDeductionResult(
          success: false,
          message: 'No inventory item was deducted.',
          usedItems: usedItems,
          skippedItems: skippedItems,
        );
      }

      return CookNowDeductionResult(
        success: true,
        message: 'Recipe cooked successfully. Inventory updated.',
        usedItems: usedItems,
        skippedItems: skippedItems,
      );
    } catch (e) {
      return CookNowDeductionResult(
        success: false,
        message: 'Failed to update inventory. Please try again.',
        usedItems: const [],
        skippedItems: [e.toString()],
      );
    }
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? _findMatchingInventoryDoc({
    required String ingredient,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) {
    for (final doc in docs) {
      final data = doc.data();
      final itemName = _cleanName((data['name'] ?? '').toString());

      if (itemName == ingredient) {
        return doc;
      }

      if (itemName.contains(ingredient) || ingredient.contains(itemName)) {
        return doc;
      }
    }

    return null;
  }

  Future<void> _saveActivity({
    required String userId,
    required String itemName,
    required String recipeTitle,
  }) async {
    final activityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('activities');

    await activityRef.add({
      'type': 'stock_out',
      'title': 'Ingredient used',
      'message': '$itemName used for $recipeTitle',
      'itemName': itemName,
      'recipeTitle': recipeTitle,
      'quantityChanged': -1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _cleanName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }

  bool _isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.isBefore(today);
  }
}
