import 'package:flutter/material.dart';
import 'package:flutter_pos/app/services/auth/sign_in_with_google.dart';
import 'package:flutter_pos/presentation/screens/account/account_screen.dart';
import 'package:flutter_pos/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:flutter_pos/presentation/screens/home/home_screen.dart';
import 'package:flutter_pos/presentation/screens/main/main_screen.dart';
import 'package:flutter_pos/presentation/screens/products/product_detail_screen.dart';
import 'package:flutter_pos/presentation/screens/products/product_form_screen.dart';
import 'package:flutter_pos/presentation/screens/products/products_screen.dart';
import 'package:flutter_pos/presentation/screens/root_screen.dart';
import 'package:flutter_pos/presentation/screens/transactions/transactions_screen.dart';
import 'package:flutter_pos/presentation/widgets/error_handler_widget.dart';
import 'package:go_router/go_router.dart';

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
    errorBuilder: (context, state) => ErrorHandlerWidget(
      errorMessage: state.error?.message,
    ),
    routes: [
      _root,
      _auth,
    ],
  );

  static final _root = GoRoute(
    path: '/',
    builder: (context, state) {
      return const RootScreen();
    },
    redirect: (context, state) async {
      // if isAuthenticated = false, go to login screen
      // else continue to current intended route screen
      if (!await AuthService().isAuthenticated()) {
        return '/auth/sign-in';
      } else {
        return '/home';
      }
    },
    routes: [
      _main,
    ],
  );

  static final _auth = GoRoute(
    path: '/auth',
    redirect: (context, state) async {
      // if isAuthenticated = false, go to intended route screen
      // else back to main screen
      if (!await AuthService().isAuthenticated()) {
        return null;
      } else {
        return '/';
      }
    },
    routes: [
      _login,
    ],
  );

  static final _login = GoRoute(
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
    routes: [
      _home,
      _products,
      _transactions,
      _account,
    ],
  );

  static final _home = GoRoute(
    path: 'home',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: HomeScreen(),
      );
    },
  );

  static final _products = GoRoute(
    path: 'products',
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
    path: 'transactions',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: TransactionsScreen(),
      );
    },
  );

  static final _account = GoRoute(
    path: 'account',
    pageBuilder: (context, state) {
      return const NoTransitionPage<void>(
        child: AccountScreen(),
      );
    },
  );

  static final _productCreate = GoRoute(
    path: 'product-create',
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

      return ProductFormScreen(
        id: id,
      );
    },
  );

  static final _productDetail = GoRoute(
    path: 'product-detail/:id',
    builder: (context, state) {
      int? id = int.tryParse(state.pathParameters["id"] ?? '');

      if (id == null) {
        throw 'Required productId is not provided!';
      }

      return ProductDetailScreen(
        id: id,
      );
    },
  );
}
