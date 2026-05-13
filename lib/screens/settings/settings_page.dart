import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_page.dart';
import 'widgets_settings/app_info_card.dart';
import 'widgets_settings/edit_profile_dialog.dart';
import 'widgets_settings/logout_card.dart';
import 'widgets_settings/notification_settings_card.dart';
import 'widgets_settings/preferences_settings_card.dart';
import 'widgets_settings/profile_header_card.dart';
import 'widgets_settings/settings_section_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool nearExpiryAlerts = true;
  bool lowStockAlerts = true;
  bool activityUpdates = false;
  bool darkModePrep = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nearExpiryAlerts = prefs.getBool('nearExpiryAlerts') ?? true;
      lowStockAlerts = prefs.getBool('lowStockAlerts') ?? true;
      activityUpdates = prefs.getBool('activityUpdates') ?? false;
      darkModePrep = prefs.getBool('darkModePrep') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _openEditProfile(User user) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditProfileDialog(user: user),
    );

    if (updated == true && mounted) {
      await FirebaseAuth.instance.currentUser?.reload();
      setState(() {});
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your Velora account and app preferences.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 18),

            ProfileHeaderCard(
              user: user,
              onEdit: user == null ? null : () => _openEditProfile(user),
            ),

            const SizedBox(height: 18),

            const SettingsSectionCard(
              title: 'Account',
              children: [
                _AccountTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Tap profile card to update name and photo',
                ),
                _AccountTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Firebase Account',
                  subtitle: 'Connected with Firebase Authentication',
                ),
              ],
            ),

            const SizedBox(height: 16),

            NotificationSettingsCard(
              nearExpiryAlerts: nearExpiryAlerts,
              lowStockAlerts: lowStockAlerts,
              activityUpdates: activityUpdates,
              onNearExpiryChanged: (value) {
                setState(() => nearExpiryAlerts = value);
                _saveBool('nearExpiryAlerts', value);
              },
              onLowStockChanged: (value) {
                setState(() => lowStockAlerts = value);
                _saveBool('lowStockAlerts', value);
              },
              onActivityChanged: (value) {
                setState(() => activityUpdates = value);
                _saveBool('activityUpdates', value);
              },
            ),

            const SizedBox(height: 16),

            PreferencesSettingsCard(
              darkModePrep: darkModePrep,
              onDarkModeChanged: (value) {
                setState(() => darkModePrep = value);
                _saveBool('darkModePrep', value);
              },
            ),

            const SizedBox(height: 16),

            const AppInfoCard(),

            const SizedBox(height: 16),

            LogoutCard(onLogout: _handleLogout),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF7C3AED)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
    );
  }
}
