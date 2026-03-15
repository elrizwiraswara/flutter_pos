import 'package:flutter/material.dart';
import 'package:flutter_pos/app/di/app_providers.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart' hide AuthProvider;
import 'package:flutter_pos/presentation/providers/auth/auth_notifier.dart';
import 'package:flutter_pos/presentation/providers/auth/auth_state.dart';
import 'package:flutter_pos/presentation/providers/main/main_notifier.dart';
import 'package:flutter_pos/presentation/providers/main/main_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppRoutes routes;

  Widget createTestWidget({
    AuthState authState = const AuthState(),
    MainState? mainState,
  }) {
    final effectiveMainState =
        mainState ??
        MainState(
          isLoaded: false,
          isHasInternet: false,
          isHasQueuedActions: false,
          isSyncronizing: false,
          user: UserEntity(id: ''),
        );

    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() {
          return _FakeAuthNotifier(authState);
        }),
        mainNotifierProvider.overrideWith(() {
          return _FakeMainNotifier(effectiveMainState);
        }),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          routes = ref.watch(appRoutesProvider);
          return MaterialApp.router(
            routerConfig: routes.router,
          );
        },
      ),
    );
  }

  group('SignInScreen Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Welcome to Flutter POS app'), findsOneWidget);
      expect(find.text('Sign In With Google'), findsOneWidget);
    });

    testWidgets('should display sign in button', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      final button = find.text('Sign In With Google');
      expect(button, findsOneWidget);
    });
  });

  group('SignInScreen Layout Tests', () {
    testWidgets('should have proper layout structure', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  _FakeAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

class _FakeMainNotifier extends MainNotifier {
  final MainState _initialState;

  _FakeMainNotifier(this._initialState);

  @override
  MainState build() => _initialState;
}
