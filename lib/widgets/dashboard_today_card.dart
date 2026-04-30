import 'package:flutter/material.dart';

class DashboardTodayCard extends StatelessWidget {
  const DashboardTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _TodayItem(title: 'Stock In', value: '1,245.00'),
        SizedBox(width: 12),
        _TodayItem(title: 'Stock Out', value: '823.00'),
      ],
    );
  }
}

class _TodayItem extends StatelessWidget {
  final String title;
  final String value;

  const _TodayItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
