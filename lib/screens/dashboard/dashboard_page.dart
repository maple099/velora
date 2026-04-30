import 'package:flutter/material.dart';

import '../../widgets/dashboard/dashboard_chart_card.dart';
import '../../widgets/dashboard/dashboard_overview_card.dart';
import '../../widgets/dashboard/dashboard_quick_action_card.dart';
import '../../widgets/dashboard/today_overview_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color purple = Color(0xFF7C3AED);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),

              const DashboardOverviewCard(
                totalItems: 3,
                nearExpiry: 2,
                lowStock: 0,
              ),

              const SizedBox(height: 18),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 12),

              const Row(
                children: [
                  Expanded(
                    child: DashboardQuickActionCard(
                      icon: Icons.add_box_outlined,
                      title: 'Add Item',
                      color: purple,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DashboardQuickActionCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'AI Suggestions',
                      color: green,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DashboardQuickActionCard(
                      icon: Icons.notifications_none_rounded,
                      title: 'Alerts',
                      color: orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              _sectionTitle('Today Overview'),
              const SizedBox(height: 12),

              const TodayOverviewSection(),
              const SizedBox(height: 16),

              const DashboardChartCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Row(
      children: [
        Icon(Icons.menu_rounded, color: textDark, size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, Arif 👋',
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Here's what's happening today",
              style: TextStyle(color: textGrey, fontSize: 12),
            ),
          ],
        ),
        Spacer(),
        Icon(Icons.notifications_none_rounded, color: textDark, size: 24),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
