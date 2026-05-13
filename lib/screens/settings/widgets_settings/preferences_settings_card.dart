import 'package:flutter/material.dart';

import '../../settings/widgets_settings/settings_section_card.dart';

class PreferencesSettingsCard extends StatelessWidget {
  final bool darkModePrep;
  final ValueChanged<bool> onDarkModeChanged;

  const PreferencesSettingsCard({
    super.key,
    required this.darkModePrep,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Preferences',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: darkModePrep,
          onChanged: onDarkModeChanged,
          activeThumbColor: const Color(0xFF7C3AED),
          secondary: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.dark_mode_outlined,
              color: Color(0xFF7C3AED),
            ),
          ),
          title: const Text(
            'Dark Mode Prep',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          subtitle: const Text(
            'Save preference now, apply theme later',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}
