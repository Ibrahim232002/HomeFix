import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'models/user_model.dart';
import 'services/app_state_provider.dart';
import 'auth/screens/auth_screen.dart';
import 'customer/screens/customer_main_layout.dart';
import 'technician/screens/technician_main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomeFixApp());
}

class HomeFixApp extends StatelessWidget {
  const HomeFixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
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
            home: _getHomeScreen(appState),
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AppStateProvider appState) {
    if (!appState.isAuthenticated) {
      return const AuthScreen();
    }

    if (appState.currentRole == UserRole.technician) {
      return const TechnicianMainLayout();
    }

    return const CustomerMainLayout();
  }
}
