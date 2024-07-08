import 'package:flutter/material.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/providers/main/main_provider.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            user(context),
            profilButton(context),
            signOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget user(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, provider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
        child: Column(
          children: [
            AppImage(
              image: provider.user?.imageUrl ?? '',
              width: 120,
              height: 120,
              borderRadius: 100,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: AppSizes.padding),
            Text(
              provider.user?.name ?? '(No Name)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.padding / 4),
            Text(
              provider.user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }

  Widget profilButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            )
          ],
        ),
        onTap: () {
          context.go('/account/profile');
        },
      ),
    );
  }

  Widget signOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.exit_to_app_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            )
          ],
        ),
        onTap: () {
          AppDialog.show(
            title: 'Confirm',
            text: 'Are you sure want to sign out?',
            leftButtonText: 'Cancel',
            rightButtonText: 'Sign Out',
            onTapRightButton: () async {
              context.pop();
              await AuthService().signOut();
              AppRoutes.router.refresh();
            },
          );
        },
      ),
    );
  }
}
