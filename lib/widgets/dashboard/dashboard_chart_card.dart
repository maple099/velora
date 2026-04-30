import 'package:flutter/material.dart';

class DashboardChartCard extends StatelessWidget {
  final List<int> weeklyData;

  const DashboardChartCard({super.key, required this.weeklyData});

  int get _maxValue {
    if (weeklyData.isEmpty) return 1;
    final max = weeklyData.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1 : max;
  }

  int get _totalThisWeek {
    return weeklyData.fold(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 14),

          SizedBox(
            height: 105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weeklyData.length > index ? weeklyData[index] : 0;
                final heightFactor = value / _maxValue;

                return Expanded(
                  child: _bar(
                    value: value,
                    day: days[index],
                    active: index == DateTime.now().weekday - 1,
                    heightFactor: heightFactor,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),
          _weeklyInsight(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Inventory Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Live Weekly',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7C3AED),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar({
    required int value,
    required String day,
    required bool active,
    required double heightFactor,
  }) {
    final barHeight = value == 0 ? 8.0 : 70 * heightFactor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 18,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                  )
                : null,
            color: active ? null : const Color(0xFFEDE9FE),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _weeklyInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            size: 18,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_totalThisWeek total item activity this week',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
