import 'package:flutter/material.dart';

class DashboardOverviewCard extends StatelessWidget {
  final int totalItems;
  final int nearExpiry;
  final int lowStock;

  const DashboardOverviewCard({
    super.key,
    required this.totalItems,
    required this.nearExpiry,
    required this.lowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 10,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(70),
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),

          Positioned(
            right: 4,
            bottom: 6,
            child: Image.asset(
              'assets/images/ai_robot.png',
              width: 95,
              height: 95,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 80,
                );
              },
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Total Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _stat(totalItems.toString(), 'Total Items'),
                  _line(),
                  _stat(nearExpiry.toString(), 'Near Expiry'),
                  _line(),
                  _stat(lowStock.toString(), 'Low Stock'),
                  const SizedBox(width: 95),
                ],
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.28),
    );
  }
}
