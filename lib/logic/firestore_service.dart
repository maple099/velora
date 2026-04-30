import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final CollectionReference _inventoryRef = FirebaseFirestore.instance
      .collection('inventory');

  // 🔥 REAL-TIME STREAM
  Stream<List<InventoryItem>> getItems() {
    return _inventoryRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
    });
  }

  // ➕ ADD ITEM
  Future<void> addItem(InventoryItem item) async {
    await _inventoryRef.add(item.toMap());
  }

  // ❌ DELETE ITEM
  Future<void> deleteItem(String id) async {
    await _inventoryRef.doc(id).delete();
  }

  // ✏️ UPDATE ITEM
  Future<void> updateItem(InventoryItem item) async {
    await _inventoryRef.doc(item.id).update(item.toMap());
  }
}
