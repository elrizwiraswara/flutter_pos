import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../services/auth/auth_service.dart';

// App routes
class AppRoutes {
  // This class is not meant to be instatiated or extended; this constructor
  // prevents instantiation and extension.
  AppRoutes._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final navNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

  static final router = GoRouter(
    initialLocation: '/home',
    navigatorKey: rootNavigatorKey,
    errorBuilder: (context, state) => ErrorScreen(
      errorMessage: state.error?.message,
    ),
    redirect: (context, state) async {
      // if isAuthenticated = false, go to sign-in screen
      // else continue to current intended route screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth/sign-in';
      } else {
        return null;
      }
    },
    routes: [
      _main,
      _auth,
      _error,
    ],
  );

  static final _error = GoRoute(
    path: '/error',
    builder: (context, state) {
      return ErrorScreen(
        errorDetails: state.extra as FlutterErrorDetails?,
      );
    },
  );

  static final _auth = GoRoute(
    path: '/auth',
    redirect: (context, state) async {
      // if isAuthenticated = false, go to intended route screen
      // else back to main screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth/sign-in';
      } else {
        return '/home';
      }
    },
    routes: [
      _signIn,
    ],
  );

  static final _signIn = GoRoute(
    path: 'sign-in',
    builder: (context, state) {
      return const SignInScreen();
    },
  );

  static final _main = ShellRoute(
    navigatorKey: navNavigatorKey,
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return MainScreen(child: child);
    },
    redirect: (context, state) async {
      // if isAuthenticated = true, go to intended route screen
      // else return to auth screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth';
      } else {
        return null;
      }
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
