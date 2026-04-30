import 'package:flutter/material.dart';

import '../../logic/firestore_service.dart';

class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WeeklyInventoryActivity>>(
      stream: FirestoreService.instance.getWeeklyActivityStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? _emptyData();
        final weeklyData = data.map((item) => item.total).toList();

        return _ChartContent(weeklyData: weeklyData);
      },
    );
  }

  List<WeeklyInventoryActivity> _emptyData() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return List.generate(7, (index) {
      return WeeklyInventoryActivity(day: days[index], stockIn: 0, stockOut: 0);
    });
  }
}

class _ChartContent extends StatelessWidget {
  final List<int> weeklyData;

  const _ChartContent({required this.weeklyData});

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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          const SizedBox(height: 16),
          SizedBox(
            height: 138,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 34,
                  child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final value = weeklyData.length > index
                        ? weeklyData[index]
                        : 0;

                    return Expanded(
                      child: _bar(
                        value: value,
                        day: days[index],
                        active: index == DateTime.now().weekday - 1,
                        heightFactor: value / _maxValue,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _weeklyInsight(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Track your inventory changes this week',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF7C3AED)),
              SizedBox(width: 7),
              Text(
                'Live Weekly',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
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
    final barHeight = value == 0 ? 9.0 : 78 * heightFactor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: active ? 13 : 11,
            fontWeight: FontWeight.w900,
            color: active ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 26,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: active ? 12 : 0,
            vertical: active ? 4 : 0,
          ),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF3E8FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: active ? const Color(0xFF7C3AED) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weeklyInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: Color(0xFF7C3AED),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_totalThisWeek total item activity this week',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
