import 'package:flutter/material.dart';

class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(painter: _LineChartPainter(), child: Container()),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF7C3AED).withValues(alpha: 0.16),
          const Color(0xFF7C3AED).withValues(alpha: 0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path linePath = Path();
    final Path fillPath = Path();

    final List<Offset> points = [
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.10, size.height * 0.70),
      Offset(size.width * 0.20, size.height * 0.58),
      Offset(size.width * 0.30, size.height * 0.65),
      Offset(size.width * 0.40, size.height * 0.52),
      Offset(size.width * 0.50, size.height * 0.72),
      Offset(size.width * 0.62, size.height * 0.36),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.82, size.height * 0.52),
      Offset(size.width * 0.90, size.height * 0.38),
      Offset(size.width, size.height * 0.30),
    ];

    linePath.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlPoint = Offset((previous.dx + current.dx) / 2, previous.dy);

      linePath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        current.dx,
        current.dy,
      );

      fillPath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        current.dx,
        current.dy,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
