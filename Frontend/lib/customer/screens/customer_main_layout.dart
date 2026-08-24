import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import 'customer_home_screen.dart';
import 'customer_requests_screen.dart';
import '../../common/screens/chat_list_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainLayout extends StatelessWidget {
  const CustomerMainLayout({Key? key}) : super(key: key);

  static final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const CustomerRequestsScreen(),
    const ChatListScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: appState.customerNavIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomerBottomNav(
          currentIndex: appState.customerNavIndex,
          onTap: (index) => appState.setCustomerNavIndex(index),
        ),
      ),
    );
  }
}
