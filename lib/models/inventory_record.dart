import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryRecord {
  final String id;
  final String itemName;
  final String type;
  final int quantity;
  final DateTime createdAt;

  InventoryRecord({
    required this.id,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.createdAt,
  });

  factory InventoryRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InventoryRecord(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'type': type,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
