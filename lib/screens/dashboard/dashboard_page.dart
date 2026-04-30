import 'package:flutter/material.dart';

import '../../widgets/dashboard_chart_card.dart';
import '../../widgets/dashboard_overview_card.dart';
import '../../widgets/dashboard_quick_action_card.dart';
import '../../widgets/dashboard_today_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            const DashboardOverviewCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            const DashboardQuickActionCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Today Overview'),
            const SizedBox(height: 12),
            const DashboardTodayCard(),
            const SizedBox(height: 16),
            const DashboardChartCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.menu_rounded, size: 28, color: Color(0xFF111827)),
        const SizedBox(width: 20),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Arif 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Here's what's happening today",
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF374151),
              ),
            ),
            Positioned(
              right: 10,
              top: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}
