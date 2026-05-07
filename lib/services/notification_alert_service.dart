import 'package:cloud_firestore/cloud_firestore.dart';

class NearExpiryAlert {
  final String itemName;
  final int daysLeft;
  final DateTime expiryDate;

  NearExpiryAlert({
    required this.itemName,
    required this.daysLeft,
    required this.expiryDate,
  });

  String get message {
    if (daysLeft == 0) return '$itemName expires today.';
    if (daysLeft == 1) return '$itemName expires tomorrow.';
    return '$itemName expires in $daysLeft days.';
  }
}

class LowStockAlert {
  final String itemName;
  final int quantity;

  LowStockAlert({required this.itemName, required this.quantity});

  String get message {
    if (quantity <= 0) return '$itemName is out of stock.';
    if (quantity == 1) return '$itemName is running low. Only 1 left.';
    return '$itemName is running low. Only $quantity left.';
  }
}

class NotificationAlertService {
  static List<NearExpiryAlert> getNearExpiryAlerts(
    List<QueryDocumentSnapshot> docs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alerts = <NearExpiryAlert>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? '').toString().trim();
      final expiry = data['expiryDate'];

      if (name.isEmpty || expiry == null || expiry is! Timestamp) continue;

      final rawDate = expiry.toDate();
      final expiryDate = DateTime(rawDate.year, rawDate.month, rawDate.day);
      final daysLeft = expiryDate.difference(today).inDays;

      if (daysLeft >= 0 && daysLeft <= 4) {
        alerts.add(
          NearExpiryAlert(
            itemName: name,
            daysLeft: daysLeft,
            expiryDate: expiryDate,
          ),
        );
      }
    }

    alerts.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return alerts;
  }

  static List<LowStockAlert> getLowStockAlerts(
    List<QueryDocumentSnapshot> docs,
  ) {
    final alerts = <LowStockAlert>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? '').toString().trim();
      final quantityRaw = data['quantity'];

      if (name.isEmpty) continue;

      int quantity = 0;

      if (quantityRaw is int) {
        quantity = quantityRaw;
      } else if (quantityRaw is double) {
        quantity = quantityRaw.toInt();
      } else {
        quantity = int.tryParse(quantityRaw.toString()) ?? 0;
      }

      if (quantity <= 2) {
        alerts.add(LowStockAlert(itemName: name, quantity: quantity));
      }
    }

    alerts.sort((a, b) => a.quantity.compareTo(b.quantity));
    return alerts;
  }
}
