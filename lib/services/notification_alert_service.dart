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
    if (daysLeft == 0) {
      return '$itemName expires today.';
    }

    if (daysLeft == 1) {
      return '$itemName expires tomorrow.';
    }

    return '$itemName expires in $daysLeft days.';
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

      if (name.isEmpty || expiry == null || expiry is! Timestamp) {
        continue;
      }

      final expiryDateRaw = expiry.toDate();
      final expiryDate = DateTime(
        expiryDateRaw.year,
        expiryDateRaw.month,
        expiryDateRaw.day,
      );

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
}
