import 'package:flutter/material.dart';

class DashboardChartCard extends StatelessWidget {
  final List<int> weeklyData;

  const DashboardChartCard({super.key, required this.weeklyData});

  int get _maxValue {
    if (weeklyData.isEmpty) return 1;

    final max = weeklyData.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1 : max;
  }

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weeklyData.length > index ? weeklyData[index] : 0;
                final heightFactor = value / _maxValue;

                return Expanded(
                  child: _bar(
                    value: value,
                    heightFactor: heightFactor,
                    day: days[index],
                    active: index == DateTime.now().weekday - 1,
                  ),
                );
              }),
            ),
          ),
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
    required double heightFactor,
    required String day,
    required bool active,
  }) {
    final barHeight = value == 0 ? 10.0 : 88 * heightFactor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  )
                : null,
            color: active ? null : const Color(0xFFEDE9FE),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
