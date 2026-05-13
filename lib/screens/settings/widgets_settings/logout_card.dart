import 'package:flutter/material.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLogout,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFFEE2E2),
              child: Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Sign out from your Velora account',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }
}
