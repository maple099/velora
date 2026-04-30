import 'package:flutter/material.dart';

class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(
        child: Icon(
          Icons.show_chart_rounded,
          color: Color(0xFF7C3AED),
          size: 85,
        ),
      ),
    );
  }
}
