import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/screens/account/about_screen.dart';
import '../../presentation/screens/account/account_screen.dart';
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
import '../di/dependency_injection.dart';
import 'params/error_screen_param.dart';

/// App routes
class AppRoutes {
  final AuthProvider _authProvider;

  AppRoutes(this._authProvider) {
    _initialize();
  }

  // Static convenience getter - returns the same instance from GetIt
  static AppRoutes get instance => di<AppRoutes>();

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  GoRouter? _router;
  GoRouter get router {
    if (_router == null) _initialize();
    return _router!;
  }

  void _initialize() {
    _router = GoRouter(
      initialLocation: '/',
      navigatorKey: rootNavigatorKey,
      refreshListenable: _authProvider.isAuthenticated,
      errorBuilder: (context, state) => ErrorScreen(param: ErrorScreenParam(error: state.error)),
      routes: [_splash],
    );
  }

  static final _splash = GoRoute(
    path: '/',
    builder: (context, state) => const WelcomeScreen(),
    redirect: (context, state) {
      final isChecking = instance._authProvider.isChecking.value;
      final isAuthenticated = instance._authProvider.isAuthenticated.value;
      final isSplashRoute = state.fullPath == '/';
      final isAuthRoute = state.fullPath?.startsWith('/sign-in') ?? false;

      print(
        'state.fullPath: ${state.fullPath}',
      );
      print(
        'isAuthenticated: $isAuthenticated, isChecking: $isChecking, isSplashRoute: $isSplashRoute, isAuthRoute: $isAuthRoute',
      );

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
      _main,
      _signIn,
      _error,
    ],
  );

  static final _error = GoRoute(
    path: '/error',
    builder: (context, state) {
      if (state.extra == null || state.extra! is! ErrorScreenParam) {
        throw 'Required ErrorScreenParam is not provided!';
      }

      return ErrorScreen(param: state.extra as ErrorScreenParam);
    },
  );

  static final _signIn = GoRoute(
    path: '/sign-in',
    builder: (context, state) {
      return const SignInScreen();
    },
  );

  static final _main = ShellRoute(
    navigatorKey: navNavigatorKey,
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return MainScreen(child: child);
    },
    routes: [
      _home,
      _products,
      _transactions,
      _account,
    ],
  );

  static final _home = GoRoute(
    path: '/home',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: HomeScreen(),
      );
    },
  );

  static final _products = GoRoute(
    path: '/products',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: ProductsScreen(),
      );
    },
    routes: [
      _productCreate,
      _productEdit,
      _productDetail,
    ],
  );

  static final _transactions = GoRoute(
    path: '/transactions',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: TransactionsScreen(),
      );
    },
    routes: [
      _transactionDetail,
    ],
  );

  static final _account = GoRoute(
    path: '/account',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: AccountScreen(),
      );
    },
    routes: [
      _profileEdit,
      _about,
    ],
  );

  static final _productCreate = GoRoute(
    path: 'product-create',
    parentNavigatorKey: navNavigatorKey,
    builder: (context, state) {
      return const ProductFormScreen();
    },
  );

  static final _productEdit = GoRoute(
    path: 'product-edit/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return ProductFormScreen(id: id);
    },
  );

  static final _productDetail = GoRoute(
    path: 'product-detail/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return ProductDetailScreen(id: id);
    },
  );

  static final _transactionDetail = GoRoute(
    path: 'transaction-detail/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return TransactionDetailScreen(id: id);
    },
  );

  static final _profileEdit = GoRoute(
    path: 'profile',
    builder: (context, state) {
      return const ProfileFormScreen();
    },
  );

  static final _about = GoRoute(
    path: 'about',
    builder: (context, state) {
      return const AboutScreen();
    },
  );
}
