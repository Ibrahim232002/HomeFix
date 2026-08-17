import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_session_provider.dart';
import 'auth/screens/auth_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'customer/screens/customer_main_layout.dart';
import 'models/user_model.dart';
import 'services/app_state_provider.dart';
import 'technician/screens/technician_main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomeFixApp());
}

class HomeFixApp extends StatelessWidget {
  const HomeFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthSessionProvider>(
          create: (_) => AuthSessionProvider()..restoreSession(),
        ),
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(),
        ),
      ],
      child: Consumer<AuthSessionProvider>(
        builder: (context, session, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, widget) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: widget ?? const SizedBox.shrink(),
              );
            },
            home: _getHomeScreen(session),
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AuthSessionProvider session) {
    switch (session.status) {
      case AuthSessionStatus.restoringSession:
        return const _SessionRestoringScreen();
      case AuthSessionStatus.unauthenticated:
        return const AuthScreen();
      case AuthSessionStatus.refreshing:
      case AuthSessionStatus.authenticated:
        return session.role == UserRole.technician
            ? const TechnicianMainLayout()
            : const CustomerMainLayout();
    }
  }
}

class _SessionRestoringScreen extends StatelessWidget {
  const _SessionRestoringScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
