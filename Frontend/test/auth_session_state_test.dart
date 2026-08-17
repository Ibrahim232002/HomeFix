import 'package:flutter_test/flutter_test.dart';
import 'package:homefix/auth/auth_session_provider.dart';

void main() {
  test('auth session exposes the expected lifecycle states', () {
    expect(AuthSessionStatus.values, <AuthSessionStatus>[
      AuthSessionStatus.restoringSession,
      AuthSessionStatus.unauthenticated,
      AuthSessionStatus.authenticated,
      AuthSessionStatus.refreshing,
    ]);
  });
}
