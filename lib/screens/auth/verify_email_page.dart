import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_page.dart';
import 'login_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isChecking = false;
  bool isResending = false;

  Future<void> checkVerificationStatus() async {
    setState(() => isChecking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showMessage('No active account found. Please login again.', true);

        if (!mounted) return;
        setState(() => isChecking = false);
        return;
      }

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        showMessage(
          'Email is not verified yet. Please click the link in your email.',
          true,
        );
      }
    } catch (_) {
      showMessage('Failed to check verification. Please try again.', true);
    }

    if (mounted) {
      setState(() => isChecking = false);
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() => isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showMessage('No active account found. Please login again.', true);

        if (!mounted) return;
        setState(() => isResending = false);
        return;
      }

      await user.sendEmailVerification();

      showMessage(
        'Verification email sent again. Please check your inbox.',
        false,
      );
    } catch (_) {
      showMessage('Failed to resend email. Please wait and try again.', true);
    }

    if (mounted) {
      setState(() => isResending = false);
    }
  }

  Future<void> logoutAndGoLogin() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: logoutAndGoLogin,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(height: 18),
              const _VeloraLogo(),
              const SizedBox(height: 30),
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to:\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.mark_email_read_rounded,
                      color: Color(0xFF7C3AED),
                      size: 42,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Open your email inbox and click the verification link from Firebase/Velora. After that, return here and tap the button below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isChecking ? null : checkVerificationStatus,
                  icon: isChecking
                      ? const SizedBox(
                          height: 19,
                          width: 19,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: Text(
                    isChecking ? 'Checking...' : 'I Have Verified',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFC4B5FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: isResending ? null : resendVerificationEmail,
                  icon: isResending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.3),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    isResending ? 'Sending...' : 'Resend Verification Email',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: logoutAndGoLogin,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VeloraLogo extends StatelessWidget {
  const _VeloraLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'V',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 18,
            right: 20,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 18,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
