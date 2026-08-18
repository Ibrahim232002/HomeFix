import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../widgets/technician_bottom_nav.dart';
import 'technician_dashboard_redesign.dart';
import 'technician_requests_screen.dart';
import 'technician_bookings_screen.dart';
import 'technician_wallet_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianMainLayout extends StatelessWidget {
  const TechnicianMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      body: IndexedStack(
        index: appState.technicianNavIndex,
        children: const [
          TechnicianDashboardRedesign(),
          TechnicianRequestsScreen(),
          TechnicianBookingsScreen(),
          TechnicianWalletScreen(),
          TechnicianProfileScreen(),
        ],
      ),
      bottomNavigationBar: TechnicianBottomNav(
        currentIndex: appState.technicianNavIndex,
        onTap: appState.setTechnicianNavIndex,
      ),
    );
  }
}
