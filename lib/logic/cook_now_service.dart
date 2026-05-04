import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';

class CookNowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cookRecipe(List<InventoryItem> usedItems) async {
    if (usedItems.isEmpty) {
      throw Exception('No matching inventory ingredients found.');
    }

    final batch = _firestore.batch();

    for (final item in usedItems) {
      final int newQuantity = item.quantity - 1;

      final itemRef = _firestore.collection('inventory').doc(item.id);

      batch.update(itemRef, {'quantity': newQuantity < 0 ? 0 : newQuantity});

      final recordRef = _firestore.collection('inventory_records').doc();

      batch.set(recordRef, {
        'itemId': item.id,
        'itemName': item.name,
        'type': 'stock_out',
        'quantity': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
