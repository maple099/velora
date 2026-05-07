import 'package:flutter/material.dart';

class NotificationHeaderCard extends StatelessWidget {
  final int total;
  final int unread;
  final VoidCallback onReadAll;

  const NotificationHeaderCard({
    super.key,
    required this.total,
    required this.unread,
    required this.onReadAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(Icons.notifications_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$total active alert(s)\n$unread unread notification(s)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: onReadAll,
            child: const Text(
              'Read all',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
