import 'package:flutter/material.dart';

class DashboardQuickActionCard extends StatelessWidget {
  const DashboardQuickActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _card(
            icon: Icons.add_box_outlined,
            title: 'Add Item',
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _card(
            icon: Icons.lightbulb_outline_rounded,
            title: 'AI Suggestions',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _card(
            icon: Icons.notifications_none_rounded,
            title: 'Alerts',
            color: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
