import 'package:flutter/material.dart';

class DashboardQuickActionCard extends StatelessWidget {
  const DashboardQuickActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionItem(
          icon: Icons.add_box_outlined,
          title: 'Add Item',
          color: const Color(0xFF7C3AED),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionItem(
          icon: Icons.lightbulb_outline_rounded,
          title: 'AI Suggestions',
          color: const Color(0xFF10B981),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ActionItem(
          icon: Icons.notifications_none_rounded,
          title: 'Alerts',
          color: const Color(0xFFF97316),
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 92,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 29),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
