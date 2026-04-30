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

    await _addRecord(
      itemName: item.name,
      type: 'stock_in',
      quantity: item.quantity,
    );
  }

  Future<void> markStockOut({
    required InventoryItem item,
    required int usedQuantity,
  }) async {
    final newQuantity = item.quantity - usedQuantity;

    if (newQuantity < 0) {
      throw Exception('Used quantity cannot exceed current stock');
    }

    await _inventoryRef.doc(item.id).update({'quantity': newQuantity});

    await _addRecord(
      itemName: item.name,
      type: 'stock_out',
      quantity: usedQuantity,
    );
  }

  Future<void> deleteItem(String id) async {
    await _inventoryRef.doc(id).delete();
  }

  Future<void> updateItem(InventoryItem item) async {
    await _inventoryRef.doc(item.id).update(item.toMap());
  }

  Future<void> _addRecord({
    required String itemName,
    required String type,
    required int quantity,
  }) async {
    final record = InventoryRecord(
      id: '',
      itemName: itemName,
      type: type,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    await _recordsRef.add(record.toMap());
  }
}
