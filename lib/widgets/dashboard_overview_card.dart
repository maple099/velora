import 'package:flutter/material.dart';

class DashboardOverviewCard extends StatelessWidget {
  const DashboardOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -8,
            child: Icon(
              Icons.eco_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          Positioned(
            right: -5,
            bottom: -8,
            child: Image.asset(
              'assets/images/ai_robot.png',
              width: 125,
              height: 125,
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 105),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total Overview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    _OverviewNumber(title: '128', label: 'Total Items'),
                    _LineDivider(),
                    _OverviewNumber(title: '12', label: 'Near Expiry'),
                    _LineDivider(),
                    _OverviewNumber(title: '7', label: 'Low Stock'),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewNumber extends StatelessWidget {
  final String title;
  final String label;

  const _OverviewNumber({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineDivider extends StatelessWidget {
  const _LineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}
