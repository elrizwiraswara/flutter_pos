import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/main/main_provider.dart';
import '../welcome/welcome_screen.dart';

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
  final _authProvider = di<AuthProvider>();
  final _mainProvider = di<MainProvider>()..resetStates();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _authProvider.checkIsAuthenticated();
      await _mainProvider.initMainProvider();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        // Display RootScreen when data is being load
        if (!provider.isLoaded) {
          return const WelcomeScreen();
        }

        // User data might still null for the first time app open or login without internet connection
        // So, throw error with a first time internet error message then the [ErrorScreen] will be shown
        if (provider.isLoaded && provider.user == null && !provider.isHasInternet) {
          throw Constants.firstTimeInternetErrorMessage;
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
            currentIndex: _calculateSelectedIndex(),
            onTap: (int idx) => _onItemTapped(idx),
          ),
        );
      },
    );
  }

  int _calculateSelectedIndex() {
    final String location = AppRoutes.instance.router.state.uri.path;

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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        AppRoutes.instance.router.go('/home');
      case 1:
        AppRoutes.instance.router.go('/products');
      case 2:
        AppRoutes.instance.router.go('/transactions');
      case 3:
        AppRoutes.instance.router.go('/account');
    }
  }
}
