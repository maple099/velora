import 'package:flutter/material.dart';

import '../../logic/firestore_service.dart';
import '../../models/inventory_item.dart';
import '../../models/inventory_record.dart';
import '../../widgets/dashboard/dashboard_chart_card.dart';
import '../../widgets/dashboard/dashboard_overview_card.dart';
import '../../widgets/dashboard/dashboard_quick_action_card.dart';
import '../../widgets/dashboard/dashboard_today_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  int _nearExpiryCount(List<InventoryItem> items) {
    return items.where((item) {
      final daysLeft = item.expiryDate.difference(DateTime.now()).inDays;
      return daysLeft >= 0 && daysLeft <= 3;
    }).length;
  }

  int _lowStockCount(List<InventoryItem> items) {
    return items.where((item) => item.quantity <= 2).length;
  }

  int _todayTotal(List<InventoryRecord> records, String type) {
    return records
        .where((record) {
          return record.type == type && _isSameDay(record.createdAt);
        })
        .fold(0, (total, record) => total + record.quantity);
  }

  List<int> _weeklyStockIn(List<InventoryRecord> records) {
    final weekly = List<int>.filled(7, 0);

    for (final record in records) {
      if (record.type != 'stock_in') continue;

      final index = record.createdAt.weekday - 1;
      weekly[index] += record.quantity;
    }

    return weekly;
  }

  bool _isSameDay(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: FirestoreService.instance.getItems(),
      builder: (context, itemSnapshot) {
        final items = itemSnapshot.data ?? [];

        return StreamBuilder<List<InventoryRecord>>(
          stream: FirestoreService.instance.getRecords(),
          builder: (context, recordSnapshot) {
            final records = recordSnapshot.data ?? [];

            final totalItems = items.length;
            final nearExpiry = _nearExpiryCount(items);
            final lowStock = _lowStockCount(items);

            final stockInToday = _todayTotal(records, 'stock_in');
            final stockOutToday = _todayTotal(records, 'stock_out');
            final weeklyData = _weeklyStockIn(records);

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 22),
                      DashboardOverviewCard(
                        totalItems: totalItems,
                        nearExpiry: nearExpiry,
                        lowStock: lowStock,
                      ),
                      const SizedBox(height: 22),
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 14),
                      const DashboardQuickActionCard(),
                      const SizedBox(height: 26),
                      _sectionTitle('Today Overview'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardTodayCard(
                              title: 'Stock In',
                              value: stockInToday.toString(),
                              subtitle: 'Today added',
                              icon: Icons.arrow_downward_rounded,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DashboardTodayCard(
                              title: 'Stock Out',
                              value: stockOutToday.toString(),
                              subtitle: 'Today used',
                              icon: Icons.arrow_upward_rounded,
                              color: const Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      DashboardChartCard(weeklyData: weeklyData),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _header() {
    return const Row(
      children: [
        Icon(Icons.menu_rounded, size: 28, color: Color(0xFF111827)),
        SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Arif 👋',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Here's what's happening today",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.notifications_none_rounded, color: Color(0xFF111827)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}
