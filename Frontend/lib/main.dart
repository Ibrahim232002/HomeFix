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
    return ChangeNotifierProvider<AuthSessionProvider>(
      create: (_) => AuthSessionProvider()..restoreSession(),
      child: Consumer<AuthSessionProvider>(
        builder: (context, session, _) {
          return ChangeNotifierProxyProvider<AuthSessionProvider, AppStateProvider>(
            create: (_) => AppStateProvider(session: session),
            update: (_, nextSession, appState) {
              appState!.bindSession(nextSession);
              return appState;
            },
            child: MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              builder: (context, widget) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: widget ?? const SizedBox.shrink(),
                );
              },
              home: const _HomeShell(),
            ),
          );
        },
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  AuthSessionProvider? _session;
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<AuthSessionProvider>();
    if (!identical(_session, session)) {
      _session?.removeListener(_handleSessionChanged);
      _session = session;
      _session!.addListener(_handleSessionChanged);
    }
    _handleSessionChanged();
  }

  void _handleSessionChanged() {
    final session = _session;
    if (session == null) return;

    final appState = context.read<AppStateProvider>();
    if (session.status == AuthSessionStatus.authenticated && session.user != null) {
      if (_loadedUserId != session.user!.id) {
        _loadedUserId = session.user!.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) appState.refreshAuthenticatedData();
        });
      }
    } else if (session.status == AuthSessionStatus.unauthenticated) {
      _loadedUserId = null;
      // AuthSessionProvider owns credential/session clearing. AppState data is
      // refreshed from the next authenticated session and is never used while
      // this router is unauthenticated.
    }
  }

  @override
  void dispose() {
    _session?.removeListener(_handleSessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();

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
