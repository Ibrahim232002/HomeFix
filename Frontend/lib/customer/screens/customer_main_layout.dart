import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import 'customer_home_redesign.dart';
import 'customer_requests_screen.dart';
import '../../common/screens/chat_list_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainLayout extends StatelessWidget {
  const CustomerMainLayout({super.key});

  static final List<Widget> _screens = [
    const CustomerHomeRedesign(),
    const CustomerRequestsScreen(),
    const ChatListScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      body: IndexedStack(
        index: appState.customerNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: appState.customerNavIndex,
        onTap: appState.setCustomerNavIndex,
      ),
    );
  }
}
