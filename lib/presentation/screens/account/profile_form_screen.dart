import 'dart:io';

import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/account/account_provider.dart';
import '../../providers/main/main_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final accountProvider = di<AccountProvider>()..resetStates();
  final mainProvider = di<MainProvider>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await accountProvider.initProfileForm();

      nameController.text = accountProvider.name ?? '';
      emailController.text = accountProvider.email ?? '';
      phoneController.text = accountProvider.phone ?? '';
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void onTapImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Photo'),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );

    if (croppedFile != null) {
      var file = File(croppedFile.path);
      accountProvider.onChangedImage(file);
    }
  }

  void updatedUser() async {
    var res = await AppDialog.showProgress(() {
      return accountProvider.updatedUser();
    });

    if (res.isSuccess) {
      AppRoutes.instance.router.pop();
      AppSnackBar.show('Profile updated');

      // Refresh user data
      mainProvider.getAndSyncAllUserData();
    } else {
      AppDialog.showError(error: res.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        titleSpacing: 0,
      ),
      body: Selector<AccountProvider, bool>(
        selector: (context, provider) => provider.isLoaded,
        builder: (context, isLoaded, _) {
          if (!isLoaded) {
            return const AppProgressIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImageSection(onTapImage: onTapImage),
                _NameField(controller: nameController),
                _EmailField(controller: emailController),
                _PhoneField(controller: phoneController),
                _UpdateButton(onTap: updatedUser),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final VoidCallback onTapImage;

  const _ImageSection({required this.onTapImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Image',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Consumer<AccountProvider>(
          builder: (context, provider, _) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: onTapImage,
                  child: AppImage(
                    image: provider.imageFile?.path ?? provider.imageUrl ?? '',
                    imgProvider: provider.imageFile != null ? ImgProvider.fileImage : ImgProvider.networkImage,
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    errorWidget: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.surfaceDim,
                      size: 32,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: AppIconButton(
                    icon: Icons.camera_alt_rounded,
                    iconSize: 14,
                    borderRadius: 8,
                    padding: const EdgeInsets.all(6),
                    onTap: onTapImage,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;

  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Name',
        hintText: 'Your name...',
        onChanged: di<AccountProvider>().onChangedName,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Email',
        hintText: 'Your email...',
        onChanged: di<AccountProvider>().onChangedEmail,
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Phone Number',
        hintText: 'Your phone number...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: di<AccountProvider>().onChangedPhone,
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UpdateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding * 1.5,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Update',
        onTap: onTap,
      ),
    );
  }
}
