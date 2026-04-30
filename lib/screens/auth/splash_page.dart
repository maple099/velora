import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text(
                        'V',
                        style: TextStyle(
                          fontSize: 110,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -18,
                        child: Transform.rotate(
                          angle: 0.6,
                          child: Container(
                            width: 34,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Velora',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smarter Food,\nBetter Business',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 270,
              child: CustomPaint(painter: FoodPatternPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    void leaf(double x, double y, double w, double h) {
      final path = Path()
        ..moveTo(x, y + h)
        ..quadraticBezierTo(x + w, y + h * 0.35, x + w * 0.35, y)
        ..quadraticBezierTo(x - w * 0.25, y + h * 0.35, x, y + h);
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(x, y + h),
        Offset(x + w * 0.25, y + h * 0.2),
        paint,
      );
    }

    void circleFruit(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, paint);
      leaf(x + r * 0.3, y - r * 1.5, 18, 28);
    }

    circleFruit(30, 150, 34);
    circleFruit(110, 200, 24);
    circleFruit(size.width - 20, 45, 40);

    leaf(80, 95, 30, 48);
    leaf(150, 65, 24, 38);
    leaf(205, 120, 26, 44);
    leaf(260, 80, 24, 40);
    leaf(310, 145, 28, 46);

    final banana = Path()
      ..moveTo(210, 220)
      ..quadraticBezierTo(280, 270, 330, 190)
      ..quadraticBezierTo(270, 230, 220, 180);
    canvas.drawPath(banana, paint);

    final branch = Path()
      ..moveTo(120, 170)
      ..quadraticBezierTo(180, 140, 250, 160)
      ..quadraticBezierTo(300, 175, 340, 145);
    canvas.drawPath(branch, paint);

    for (final p in [
      const Offset(95, 130),
      const Offset(150, 110),
      const Offset(250, 135),
      const Offset(285, 170),
      const Offset(340, 105),
    ]) {
      canvas.drawCircle(p, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
