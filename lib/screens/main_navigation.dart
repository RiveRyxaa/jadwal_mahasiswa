import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'jadwal/jadwal_screen.dart';
import 'tugas/tugas_screen.dart';
import 'profil/profil_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  /// Allow child screens to switch tabs
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationState>();
    state?._setTab(index);
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  final _screens = const [
    DashboardScreen(),
    JadwalScreen(),
    TugasScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  isSelected: _currentIndex == 0,
                  onTap: () => _setTab(0),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  label: 'Jadwal',
                  isSelected: _currentIndex == 1,
                  onTap: () => _setTab(1),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.check_circle_outline,
                  activeIcon: Icons.check_circle_rounded,
                  label: 'Tugas',
                  isSelected: _currentIndex == 2,
                  onTap: () => _setTab(2),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  isSelected: _currentIndex == 3,
                  onTap: () => _setTab(3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurpleVeryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryPurple
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryPurple
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
