import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Alerts',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final now = DateTime.now();

          final alerts = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final quantity = (data['quantity'] ?? 0) as num;
            final expiry = data['expiryDate'];

            final isLowStock = quantity.toInt() <= 5;
            bool isNearExpiry = false;

            if (expiry is Timestamp) {
              final expiryDate = expiry.toDate();
              final diff = expiryDate.difference(now).inDays;

              isNearExpiry = diff >= 0 && diff <= 4;
            }

            return isLowStock || isNearExpiry;
          }).toList();

          if (alerts.isEmpty) {
            return const Center(
              child: Text(
                'No alerts 🎉',
                style: TextStyle(
                  fontSize: 14,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Item';
              final quantity = (data['quantity'] ?? 0) as num;
              final expiry = data['expiryDate'];

              final isLowStock = quantity.toInt() <= 5;
              bool isNearExpiry = false;

              if (expiry is Timestamp) {
                final expiryDate = expiry.toDate();
                final diff = expiryDate.difference(now).inDays;

                isNearExpiry = diff >= 0 && diff <= 4;
              }

              return _alertCard(
                name: name,
                quantity: quantity.toInt(),
                isLowStock: isLowStock,
                isNearExpiry: isNearExpiry,
              );
            },
          );
        },
      ),
    );
  }

  Widget _alertCard({
    required String name,
    required int quantity,
    required bool isLowStock,
    required bool isNearExpiry,
  }) {
    final alertText = isLowStock && isNearExpiry
        ? 'Low stock and expiring soon'
        : isLowStock
        ? 'Low stock: $quantity left'
        : 'Expiring soon';

    final alertColor = isLowStock ? red : orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLowStock
                  ? Icons.warning_amber_rounded
                  : Icons.access_time_rounded,
              color: alertColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alertText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
