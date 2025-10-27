import 'package:flutter/material.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart' hide AuthProvider;
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_in_screen_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUpAll(() {
    provideDummy<Result<UserEntity?>>(Result<UserEntity?>.success(data: null));
    provideDummy<Result<String>>(Result<String>.success(data: ''));
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();

    // Register mocks in service locator
    sl.registerSingleton<AuthProvider>(mockAuthProvider);

    // Register AppRoutes with mock AuthProvider
    when(mockAuthProvider.isAuthenticated).thenReturn(false);
    sl.registerSingleton<AppRoutes>(AppRoutes(mockAuthProvider));
  });

  tearDown(() {
    sl.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(
      routerConfig: sl<AppRoutes>().router,
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
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display welcome image', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(Image), findsOneWidget);
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

  group('SignInScreen Sign In Tests', () {
    testWidgets('should navigate to home on successful sign in', (tester) async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final successResult = Result<String>.success(data: user.id);

      when(mockAuthProvider.signIn()).thenAnswer((_) async => successResult);

      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In With Google'));
      await tester.pumpAndSettle();

      // assert
      verify(mockAuthProvider.signIn()).called(1);

      final router = sl<AppRoutes>().router;

      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      router.refresh();

      // Verify navigation to home by checking current location
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('should show error dialog on failed sign in', (tester) async {
      // arrange
      final failureResult = Result<String>.failure(error: 'Sign in failed');

      when(mockAuthProvider.signIn()).thenAnswer((_) async => failureResult);

      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In With Google'));
      await tester.pumpAndSettle();

      // assert
      verify(mockAuthProvider.signIn()).called(1);

      // Error dialog should be shown
      expect(find.text('Sign in failed'), findsOneWidget);
    });

    testWidgets('should call signIn only once when button tapped', (tester) async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final successResult = Result<String>.success(data: user.id);

      when(mockAuthProvider.signIn()).thenAnswer((_) async => successResult);

      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In With Google'));
      await tester.pumpAndSettle();

      // assert
      verify(mockAuthProvider.signIn()).called(1);
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

    testWidgets('should display welcome message in center', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      final expanded = find.byType(Expanded);
      expect(expanded, findsOneWidget);

      final container = find.descendant(
        of: expanded,
        matching: find.byType(Container),
      );
      expect(container, findsAtLeastNWidgets(1));
    });

    testWidgets('should have constrained width for welcome message', (tester) async {
      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(Expanded),
          matching: find.byType(Container),
        ),
      );

      // Find the container with maxWidth constraint
      final constrainedContainer = containers.firstWhere(
        (container) => container.constraints?.maxWidth == 270,
        orElse: () => throw 'Container with maxWidth 270 not found',
      );

      expect(constrainedContainer.constraints?.maxWidth, 270);
    });
  });
}
