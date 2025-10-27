import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/screens/account/about_screen.dart';
import '../../presentation/screens/account/account_screen.dart';
import '../../presentation/screens/account/profile_form_screen.dart';
import '../../presentation/screens/auth/sign_in/sign_in_screen.dart';
import '../../presentation/screens/error_handler_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/products/product_detail_screen.dart';
import '../../presentation/screens/products/product_form_screen.dart';
import '../../presentation/screens/products/products_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/transactions/transactions_screen.dart';
import '../../service_locator.dart';
import 'params/error_screen_param.dart';

// App routes
class AppRoutes {
  final AuthProvider authProvider;

  AppRoutes(this.authProvider) {
    // Called automatically when instance is created
    initRouter();
  }

  // Static convenience getter - returns the same instance from GetIt
  static AppRoutes get instance => sl<AppRoutes>();

  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  late final GoRouter _router;
  GoRouter get router => _router;

  void initRouter() async {
    await authProvider.checkIsAuthenticated();

    _router = GoRouter(
      initialLocation: '/home',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authProvider,
      errorBuilder: (context, state) => ErrorScreen(param: ErrorScreenParam(error: state.error)),
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation.startsWith('/sign-in');

        if (!isAuthenticated && !isAuthRoute) {
          return '/sign-in';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        _main,
        _signIn,
        _error,
      ],
    );
  }

  GoRoute get _error => GoRoute(
    path: '/error',
    builder: (context, state) {
      if (state.extra == null || state.extra! is ErrorScreenParam) {
        throw 'Required ErrorScreenParam is not provided!';
      }

      return ErrorScreen(param: state.extra as ErrorScreenParam);
    },
  );

  GoRoute get _signIn => GoRoute(
    path: '/sign-in',
    builder: (context, state) {
      return const SignInScreen();
    },
  );

  ShellRoute get _main => ShellRoute(
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

  GoRoute get _home => GoRoute(
    path: '/home',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: HomeScreen(),
      );
    },
  );

  GoRoute get _products => GoRoute(
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

  GoRoute get _transactions => GoRoute(
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

  GoRoute get _account => GoRoute(
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

  GoRoute get _productCreate => GoRoute(
    path: 'product-create',
    parentNavigatorKey: navNavigatorKey,
    builder: (context, state) {
      return const ProductFormScreen();
    },
  );

  GoRoute get _productEdit => GoRoute(
    path: 'product-edit/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return ProductFormScreen(id: id);
    },
  );

  GoRoute get _productDetail => GoRoute(
    path: 'product-detail/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return ProductDetailScreen(id: id);
    },
  );

  GoRoute get _transactionDetail => GoRoute(
    path: 'transaction-detail/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return TransactionDetailScreen(id: id);
    },
  );

  GoRoute get _profileEdit => GoRoute(
    path: 'profile',
    builder: (context, state) {
      return const ProfileFormScreen();
    },
  );

  GoRoute get _about => GoRoute(
    path: 'about',
    builder: (context, state) {
      return const AboutScreen();
    },
  );
}
