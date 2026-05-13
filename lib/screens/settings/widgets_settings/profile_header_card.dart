import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final User? user;
  final VoidCallback? onEdit;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Velora User';

    final email = user?.email ?? 'No email connected';
    final photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              backgroundImage: photoUrl == null || photoUrl.isEmpty
                  ? null
                  : NetworkImage(photoUrl),
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFEDE9FE),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Tap to edit profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
