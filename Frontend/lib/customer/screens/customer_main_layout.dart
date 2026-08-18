import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import 'customer_home_screen.dart';
import 'customer_requests_screen.dart';
import '../../common/screens/chat_list_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainLayout extends StatelessWidget {
  const CustomerMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      body: IndexedStack(
        index: appState.customerNavIndex,
        children: const [
          CustomerHomeScreen(),
          CustomerRequestsScreen(),
          ChatListScreen(),
          CustomerProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: appState.customerNavIndex,
        onTap: appState.setCustomerNavIndex,
      ),
    );
  }
}
