import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../widgets/technician_bottom_nav.dart';
import 'technician_dashboard_screen.dart';
import 'technician_requests_screen.dart';
import 'technician_bookings_screen.dart';
import 'technician_wallet_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianMainLayout extends StatelessWidget {
  const TechnicianMainLayout({Key? key}) : super(key: key);

  static final List<Widget> _screens = [
    const TechnicianDashboardScreen(),
    const TechnicianRequestsScreen(),
    const TechnicianBookingsScreen(),
    const TechnicianWalletScreen(),
    const TechnicianProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: appState.technicianNavIndex,
          children: _screens,
        ),
        bottomNavigationBar: TechnicianBottomNav(
          currentIndex: appState.technicianNavIndex,
          onTap: (index) => appState.setTechnicianNavIndex(index),
        ),
      ),
    );
  }
}
