import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/const/const.dart';
import '../../../service_locator.dart';
import '../../providers/main/main_provider.dart';
import '../error_handler_screen.dart';
import '../root_screen.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _mainProvider = sl<MainProvider>()..resetStates();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainProvider.initMainProvider(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        // Display RootScreen when data is being load
        if (!provider.isLoaded) {
          return const RootScreen();
        }

        // User data might still null for the first time app open or login without internet connection
        // So, display error screen with a first time internet error message
        if (provider.isLoaded && provider.user == null && !provider.isHasInternet) {
          return const ErrorScreen(errorMessage: FIRST_TIME_INTERNET_ERROR_MESSAGE);
        }

        return Scaffold(
          body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.maps_home_work_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_customize_outlined),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'Account',
              ),
            ],
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int idx) => _onItemTapped(idx, context),
          ),
        );
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/products')) {
      return 1;
    }

    if (location.startsWith('/transactions')) {
      return 2;
    }

    if (location.startsWith('/account')) {
      return 3;
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
      case 1:
        GoRouter.of(context).go('/products');
      case 2:
        GoRouter.of(context).go('/transactions');
      case 3:
        GoRouter.of(context).go('/account');
    }
  }
}
