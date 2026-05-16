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

  CollectionReference<Map<String, dynamic>> get _inventoryRef {
    return _firestore.collection('inventory');
  }

  CollectionReference<Map<String, dynamic>> get _recordsRef {
    return _firestore.collection('inventory_records');
  }

  CollectionReference<Map<String, dynamic>> get _activitiesRef {
    return _firestore.collection('activities');
  }

  Future<CookNowDeductionResult> deductRecipeIngredients({
    required String userId,
    required String recipeTitle,
    required List<String> ingredients,
  }) async {
    try {
      if (ingredients.isEmpty) {
        return const CookNowDeductionResult(
          success: false,
          message: 'No recipe ingredients found.',
          usedItems: [],
          skippedItems: [],
        );
      }

      final snapshot = await _inventoryRef.get();

      final usedItems = <String>[];
      final skippedItems = <String>[];

      final normalizedIngredients = ingredients
          .map(_cleanName)
          .where((name) => name.isNotEmpty)
          .toSet()
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

        final itemName = (data['name'] ?? ingredient).toString();
        final quantity = _toInt(data['quantity']);
        final expiryDate = _toDateTime(data['expiryDate']);

        if (quantity <= 0) {
          skippedItems.add('$itemName has no stock');
          continue;
        }

        if (expiryDate != null && _isExpired(expiryDate)) {
          skippedItems.add('$itemName is expired');
          continue;
        }

        final newQuantity = quantity - 1;

        await matchedDoc.reference.update({'quantity': newQuantity});

        await _addInventoryRecord(itemName: itemName, quantity: 1);

        await _addActivity(itemName: itemName, recipeTitle: recipeTitle);

        usedItems.add(itemName);
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

  Future<void> _addInventoryRecord({
    required String itemName,
    required int quantity,
  }) async {
    if (quantity <= 0) return;

    await _recordsRef.add({
      'itemName': itemName,
      'type': 'stock_out',
      'quantity': quantity,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> _addActivity({
    required String itemName,
    required String recipeTitle,
  }) async {
    await _activitiesRef.add({
      'type': 'stock_out',
      'title': 'Used $itemName',
      'subtitle': '$itemName used for $recipeTitle',
      'createdAt': Timestamp.now(),
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
