import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';
import '../models/inventory_record.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();

  final _inventoryRef = FirebaseFirestore.instance.collection('inventory');
  final _recordsRef = FirebaseFirestore.instance.collection(
    'inventory_records',
  );

  Stream<List<InventoryItem>> getItems() {
    return _inventoryRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<InventoryRecord>> getRecords() {
    return _recordsRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => InventoryRecord.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addItem(InventoryItem item) async {
    await _inventoryRef.add(item.toMap());

    final record = InventoryRecord(
      id: '',
      itemName: item.name,
      type: 'stock_in',
      quantity: item.quantity,
      createdAt: DateTime.now(),
    );

    await _recordsRef.add(record.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _inventoryRef.doc(id).delete();
  }

  Future<void> updateItem(InventoryItem item) async {
    await _inventoryRef.doc(item.id).update(item.toMap());
  }
}
