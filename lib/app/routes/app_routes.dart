import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth/auth_notifier.dart';
import '../../presentation/screens/account/about_screen.dart';
import '../../presentation/screens/account/account_screen.dart';
import '../../presentation/screens/account/printer_settings_screen.dart';
import '../../presentation/screens/account/profile_form_screen.dart';
import '../../presentation/screens/auth/sign_in/sign_in_screen.dart';
import '../../presentation/screens/error/error_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/products/product_detail_screen.dart';
import '../../presentation/screens/products/product_form_screen.dart';
import '../../presentation/screens/products/products_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/transactions/transactions_screen.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import 'params/error_screen_param.dart';

/// App routes
class AppRoutes {
  final Ref _ref;

  AppRoutes(this._ref) {
    _initialize();
  }

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  GoRouter? _router;
  GoRouter get router {
    if (_router == null) _initialize();
    return _router!;
  }

  void _initialize() {
    final authNotifier = _ref.read(authNotifierProvider);
    final authStateNotifier = ValueNotifier(authNotifier);

    // Dispose the notifier when the provider is disposed
    _ref.onDispose(authStateNotifier.dispose);

    // Listen to the auth state and update the ValueNotifier
    _ref.listen(authNotifierProvider, (_, value) => authStateNotifier.value = value);

    _router = GoRouter(
      initialLocation: '/',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authStateNotifier,
      errorBuilder: (context, state) => ErrorScreen(param: ErrorScreenParam(error: state.error)),
      redirect: (context, state) {
        final authState = _ref.read(authNotifierProvider);
        final isChecking = authState.isChecking;
        final isAuthenticated = authState.isAuthenticated;
        final isSplashRoute = state.fullPath == '/';
        final isAuthRoute = state.fullPath?.startsWith('/sign-in') ?? false;

        if (isChecking) {
          return '/';
        }

        if (!isAuthenticated && !isAuthRoute) {
          return '/sign-in';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return isSplashRoute ? '/home' : null;
      },
      routes: [
        _splash(),
        _main(),
        _signIn(),
        _error(),
      ],
    );
  }

  GoRoute _splash() {
    return GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    );
  }

  GoRoute _error() {
    return GoRoute(
      path: '/error',
      builder: (context, state) {
        if (state.extra == null || state.extra! is! ErrorScreenParam) {
          throw 'Required ErrorScreenParam is not provided!';
        }

        return ErrorScreen(param: state.extra as ErrorScreenParam);
      },
    );
  }

  GoRoute _signIn() {
    return GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        return const SignInScreen();
      },
    );
  }

  ShellRoute _main() {
    return ShellRoute(
      navigatorKey: navNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScreen(child: child);
      },
      routes: [
        _home(),
        _products(),
        _transactions(),
        _account(),
      ],
    );
  }

  GoRoute _home() {
    return GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: HomeScreen(),
        );
      },
    );
  }

  GoRoute _products() {
    return GoRoute(
      path: '/products',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: ProductsScreen(),
        );
      },
      routes: [
        _productCreate(),
        _productEdit(),
        _productDetail(),
      ],
    );
  }

  GoRoute _transactions() {
    return GoRoute(
      path: '/transactions',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: TransactionsScreen(),
        );
      },
      routes: [
        _transactionDetail(),
      ],
    );
  }

  GoRoute _account() {
    return GoRoute(
      path: '/account',
      pageBuilder: (context, state) {
        return const NoTransitionPage<void>(
          child: AccountScreen(),
        );
      },
      routes: [
        _profileEdit(),
        _about(),
        _printerSettings(),
      ],
    );
  }

  GoRoute _productCreate() {
    return GoRoute(
      path: 'product-create',
      parentNavigatorKey: navNavigatorKey,
      builder: (context, state) {
        return const ProductFormScreen();
      },
    );
  }

  GoRoute _productEdit() {
    return GoRoute(
      path: 'product-edit/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return ProductFormScreen(id: id);
      },
    );
  }

  GoRoute _productDetail() {
    return GoRoute(
      path: 'product-detail/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return ProductDetailScreen(id: id);
      },
    );
  }

  GoRoute _transactionDetail() {
    return GoRoute(
      path: 'transaction-detail/:id',
      builder: (context, state) {
        int? id = int.tryParse(state.pathParameters["id"] ?? '');

        if (id == null) {
          throw 'Required productId is not provided!';
        }

        return TransactionDetailScreen(id: id);
      },
    );
  }

  GoRoute _profileEdit() {
    return GoRoute(
      path: 'profile',
      builder: (context, state) {
        return const ProfileFormScreen();
      },
    );
  }

  GoRoute _about() {
    return GoRoute(
      path: 'about',
      builder: (context, state) {
        return const AboutScreen();
      },
    );
  }

  GoRoute _printerSettings() {
    return GoRoute(
      path: 'printer-settings',
      builder: (context, state) {
        return const PrinterSettingsScreen();
      },
    );
  }
}
