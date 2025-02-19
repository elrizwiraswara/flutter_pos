import 'package:flutter/material.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/core/errors/errors.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_pos/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_in_screen_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    sl.registerSingleton<AuthProvider>(mockAuthProvider);
  });

  tearDown(() {
    sl.reset(); // Reset GetIt after each test
  });

  Widget makeTestableWidget(SignInScreen signInScreen) {
    return MaterialApp(
      navigatorKey: AppRoutes.router.configuration.navigatorKey,
      home: const SignInScreen(),
    );
  }

  testWidgets('SignInScreen UI should render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(const SignInScreen()));

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Welcome to Flutter POS app'), findsOneWidget);
    expect(find.text('Sign In With Google'), findsOneWidget);
  });

  testWidgets('Clicking Sign In button should call signIn method', (WidgetTester tester) async {
    when(mockAuthProvider.signIn()).thenAnswer((_) async => Result.success('user_id'));

    await tester.pumpWidget(makeTestableWidget(const SignInScreen()));

    await tester.tap(find.text('Sign In With Google'));
    await tester.pump();

    verify(mockAuthProvider.signIn()).called(1);
  });

  testWidgets('Should show error dialog if signIn fails', (WidgetTester tester) async {
    when(mockAuthProvider.signIn())
        .thenAnswer((_) async => Result.error(const UnknownError(message: 'Sign-in failed')));

    await tester.pumpWidget(makeTestableWidget(const SignInScreen()));

    await tester.tap(find.text('Sign In With Google'));
    await tester.pump();

    expect(find.text('Sign-in failed'), findsOneWidget);
  });
}
