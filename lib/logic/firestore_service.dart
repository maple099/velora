import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';
import '../models/inventory_record.dart';

class WeeklyInventoryActivity {
  final String day;
  final int stockIn;
  final int stockOut;

  WeeklyInventoryActivity({
    required this.day,
    required this.stockIn,
    required this.stockOut,
  });

  int get total => stockIn + stockOut;
}

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

  Stream<Map<String, int>> getOverviewStream() {
    return _inventoryRef.snapshots().map((snapshot) {
      int totalItems = snapshot.docs.length;
      int nearExpiry = 0;
      int lowStock = 0;

      final today = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final quantity = (data['quantity'] ?? 0) as num;
        final expiryValue = data['expiryDate'];

        if (quantity.toInt() <= 5) {
          lowStock++;
        }

        if (expiryValue is Timestamp) {
          final expiryDate = expiryValue.toDate();
          final difference = expiryDate.difference(today).inDays;

          if (difference >= 0 && difference <= 3) {
            nearExpiry++;
          }
        }
      }

      return {
        'total': totalItems,
        'nearExpiry': nearExpiry,
        'lowStock': lowStock,
      };
    });
  }

  Stream<Map<String, int>> getTodayOverviewStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _recordsRef
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          int stockIn = 0;
          int stockOut = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final type = data['type'] ?? '';
            final quantity = (data['quantity'] ?? 0) as num;

            if (type == 'stock_in') {
              stockIn += quantity.toInt();
            }

            if (type == 'stock_out') {
              stockOut += quantity.toInt();
            }
          }

          return {'stock_in': stockIn, 'stock_out': stockOut};
        });
  }

  Stream<List<WeeklyInventoryActivity>> getWeeklyActivityStream() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _recordsRef
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map((snapshot) {
          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final stockInList = List<int>.filled(7, 0);
          final stockOutList = List<int>.filled(7, 0);

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final type = data['type'] ?? '';
            final quantity = (data['quantity'] ?? 0) as num;
            final createdAt = data['createdAt'];

            if (createdAt is! Timestamp) continue;

            final index = createdAt.toDate().weekday - 1;

            if (index < 0 || index > 6) continue;

            if (type == 'stock_in') {
              stockInList[index] += quantity.toInt();
            }

            if (type == 'stock_out') {
              stockOutList[index] += quantity.toInt();
            }
          }

          return List.generate(7, (index) {
            return WeeklyInventoryActivity(
              day: days[index],
              stockIn: stockInList[index],
              stockOut: stockOutList[index],
            );
          });
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

  Future<void> updateItem(InventoryItem item, [InventoryItem? newItem]) async {
    if (newItem == null) {
      await _inventoryRef.doc(item.id).update(item.toMap());
      return;
    }

    await _inventoryRef.doc(item.id).update(newItem.toMap());

    if (newItem.quantity > item.quantity) {
      await _addRecord(
        itemName: newItem.name,
        type: 'stock_in',
        quantity: newItem.quantity - item.quantity,
      );
    }

    if (newItem.quantity < item.quantity) {
      await _addRecord(
        itemName: newItem.name,
        type: 'stock_out',
        quantity: item.quantity - newItem.quantity,
      );
    }
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

  Future<void> _addRecord({
    required String itemName,
    required String type,
    required int quantity,
  }) async {
    if (quantity <= 0) return;

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
