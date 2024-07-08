import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/providers/account/account_provider.dart';
import 'package:flutter_pos/presentation/providers/products/product_form_provider.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';
import 'package:flutter_pos/presentation/widgets/app_icon_button.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';
import 'package:flutter_pos/presentation/widgets/app_text_field.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final accountProvider = sl<AccountProvider>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    accountProvider.clearStates();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await accountProvider.getUserDetail(AuthService().getAuthData()!.uid);

      _nameController.text = accountProvider.name ?? '';
      _emailController.text = accountProvider.email ?? '';
      _phoneController.text = accountProvider.phone ?? '';
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void onTapImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image(),
            name(),
            email(),
            phone(),
            button(),
          ],
        ),
      ),
    );
  }

  Widget image() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Consumer<ProductFormProvider>(
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
                    borderRadius: AppSizes.radius,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderWidth: 1,
                    borderColor: Theme.of(context).colorScheme.primaryContainer,
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

  Widget name() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _nameController,
        labelText: 'Name',
        hintText: 'Your name...',
        onChanged: accountProvider.onChangedName,
      ),
    );
  }

  Widget email() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _emailController,
        labelText: 'Email',
        hintText: 'Your email...',
        onChanged: accountProvider.onChangedEmail,
      ),
    );
  }

  Widget phone() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _phoneController,
        labelText: 'Phone Number',
        hintText: 'Your phone number...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: accountProvider.onChangedPhone,
      ),
    );
  }

  Widget button() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding * 1.5,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Update',
        onTap: () {
          updatedUser();
        },
      ),
    );
  }

  void updatedUser() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AppDialog.showDialogProgress();

    var err = await accountProvider.updatedUser(AuthService().getAuthData()!.uid);

    AppDialog.closeDialog();

    if (err == null) {
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } else {
      AppDialog.showErrorDialog(error: err);
    }
  }
}
