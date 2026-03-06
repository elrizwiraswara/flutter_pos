import 'dart:io';

import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = ref.read(accountControllerProvider);
      await provider.initProfileForm();

      nameController.text = provider.name ?? '';
      emailController.text = provider.email ?? '';
      phoneController.text = provider.phone ?? '';
    });
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
      ref.read(accountControllerProvider).onChangedImage(file);
    }
  }

  void updatedUser() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(accountControllerProvider).updatedUser();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.show('Profile updated');

      // Refresh user data
      ref.read(mainControllerProvider).getAndSyncAllUserData();
    } else {
      AppDialog.showError(error: res.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.read(accountControllerProvider);

    final isLoaded = ref.watch(accountControllerProvider.select((p) => p.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        titleSpacing: 0,
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageSection(onTapImage: onTapImage),
                  _NameField(controller: nameController, onChanged: account.onChangedName),
                  _EmailField(controller: emailController, onChanged: account.onChangedEmail),
                  _PhoneField(controller: phoneController, onChanged: account.onChangedPhone),
                  _UpdateButton(onTap: updatedUser),
                ],
              ),
            ),
    );
  }
}

class _ImageSection extends ConsumerWidget {
  final VoidCallback onTapImage;

  const _ImageSection({required this.onTapImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(accountControllerProvider.select((p) => p.imageFile));
    final imageUrl = ref.watch(accountControllerProvider.select((p) => p.imageUrl));

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
        Stack(
          children: [
            GestureDetector(
              onTap: onTapImage,
              child: AppImage(
                image: imageFile?.path ?? imageUrl ?? '',
                imgProvider: imageFile != null ? ImgProvider.fileImage : ImgProvider.networkImage,
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
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Name',
        hintText: 'Your name...',
        onChanged: onChanged,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _EmailField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Email',
        hintText: 'Your email...',
        onChanged: onChanged,
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.onChanged,
  });

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
        onChanged: onChanged,
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
