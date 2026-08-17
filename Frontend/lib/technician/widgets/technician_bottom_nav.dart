import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/constants/app_strings.dart';

class TechnicianBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TechnicianBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: AppStrings.navDashboard,
        ),
        NavigationDestination(
          icon: Icon(Icons.near_me_outlined),
          selectedIcon: Icon(Icons.near_me_rounded),
          label: AppStrings.navAvailableRequests,
        ),
        NavigationDestination(
          icon: Icon(Icons.event_available_outlined),
          selectedIcon: Icon(Icons.event_available_rounded),
          label: AppStrings.navMyBookings,
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: AppStrings.navWallet,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: AppStrings.navProfile,
        ),
      ],
      height: AppDesignTokens.navHeight,
      elevation: 8,
      indicatorColor: const Color(0xFFFFF3D6),
    );
  }
}
