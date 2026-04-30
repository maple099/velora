import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../inventory/inventory_page.dart';
import '../reports/reports_page.dart';
import '../suggestions/suggestions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    InventoryPage(),
    SizedBox(),
    SuggestionsPage(),
    ReportsPage(),
  ];

  void _changePage(int index) {
    if (index == 2) {
      _showAddMessage();
      return;
    }

    setState(() => _selectedIndex = index);
  }

  void _showAddMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Item page coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: _BottomBar(
        currentIndex: _selectedIndex,
        onTap: _changePage,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            text: 'Home',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.inventory_2_outlined,
            text: 'Items',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _AddButton(onTap: () => onTap(2)),
          _NavItem(
            icon: Icons.tips_and_updates_outlined,
            text: 'AI Tips',
            active: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            text: 'Reports',
            active: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF7C3AED);
    const inactiveColor = Color(0xFF9CA3AF);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
