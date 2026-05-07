import 'package:flutter/material.dart';

class NotificationEmptyView extends StatelessWidget {
  const NotificationEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No active alerts.\nYour inventory looks good.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
