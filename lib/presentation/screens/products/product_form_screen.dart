import 'dart:io';

import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class ProductFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const ProductFormScreen({
    super.key,
    this.id,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productFormProvider = ref.read(productFormControllerProvider);
      await productFormProvider.initProductForm(widget.id);

      nameController.text = productFormProvider.name ?? '';
      priceController.text = productFormProvider.price?.toString() ?? '';
      stockController.text = productFormProvider.stock?.toString() ?? '';
      descController.text = productFormProvider.description ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descController.dispose();
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
      ref.read(productFormControllerProvider).onChangedImage(file);
    }
  }

  void createProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormControllerProvider).createProduct();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/products');
      AppSnackBar.show('Product created');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updatedProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormControllerProvider).updatedProduct(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Product updated');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteProduct() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormControllerProvider).deleteProduct(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.go('/products');
      AppSnackBar.show('Product deleted');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.read(productFormControllerProvider);

    final isLoaded = ref.watch(productFormControllerProvider.select((provider) => provider.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Create Product' : 'Edit Product'),
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
                  _NameField(
                    controller: nameController,
                    onChanged: provider.onChangedName,
                  ),
                  _PriceField(
                    controller: priceController,
                    onChanged: provider.onChangedPrice,
                  ),
                  _StockField(
                    controller: stockController,
                    onChanged: provider.onChangedStock,
                  ),
                  _DescriptionField(
                    controller: descController,
                    onChanged: provider.onChangedDesc,
                  ),
                  _CreateOrUpdateButton(
                    id: widget.id,
                    onCreateProduct: createProduct,
                    onUpdatedProduct: updatedProduct,
                  ),
                  _DeleteButton(
                    id: widget.id,
                    onDeleteProduct: deleteProduct,
                  ),
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
    final imageFile = ref.watch(productFormControllerProvider.select((p) => p.imageFile));
    final imageUrl = ref.watch(productFormControllerProvider.select((p) => p.imageUrl));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image',
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
        hintText: 'Product name...',
        onChanged: onChanged,
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PriceField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Price',
        hintText: 'Product price...',
        type: AppTextFieldType.currency,
        onChanged: onChanged,
      ),
    );
  }
}

class _StockField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _StockField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Stock',
        hintText: 'Product stock...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Description',
        hintText: 'Product description...',
        maxLines: 4,
        onChanged: onChanged,
      ),
    );
  }
}

class _CreateOrUpdateButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreateProduct;
  final VoidCallback onUpdatedProduct;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreateProduct,
    required this.onUpdatedProduct,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(productFormControllerProvider.select((p) => p.isFormValid()));

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: id == null ? 'Add Product' : 'Update Product',
        enabled: isFormValid,
        onTap: () {
          if (id != null) {
            onUpdatedProduct();
          } else {
            onCreateProduct();
          }
        },
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeleteProduct;

  const _DeleteButton({
    required this.id,
    required this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (id == null) return const SizedBox(height: AppSizes.padding * 2);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Delete',
        textColor: Theme.of(context).colorScheme.error,
        buttonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        onTap: () {
          AppDialog.show(
            title: 'Confirm',
            text: 'Are you sure want to delete this product?',
            leftButtonText: 'Cancel',
            rightButtonText: 'Delete',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onDeleteProduct();
            },
          );
        },
      ),
    );
  }
}
