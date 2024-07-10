import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_sizes.dart';
import '../../../app/utilities/console_log.dart';
import '../../../service_locator.dart';
import '../../providers/products/product_form_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_text_field.dart';

class ProductFormScreen extends StatefulWidget {
  final int? id;

  const ProductFormScreen({
    super.key,
    this.id,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _productFormProvider = sl<ProductFormProvider>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    _productFormProvider.clearStates();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.id != null) {
        await _productFormProvider.getProductDetail(widget.id!);

        _nameController.text = _productFormProvider.name ?? '';
        _priceController.text = _productFormProvider.price.toString();
        _stockController.text = _productFormProvider.stock.toString();
        _descController.text = _productFormProvider.description ?? '';
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
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
      _productFormProvider.onChangedImage(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image(),
            name(),
            price(),
            stock(),
            description(),
            createOrUpdateButton(),
            deleteButton(),
          ],
        ),
      ),
    );
  }

  Widget image() {
    return Consumer<ProductFormProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Produk',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.padding / 2),
            Stack(
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
            ),
          ],
        );
      },
    );
  }

  Widget name() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _nameController,
        labelText: 'Nama',
        hintText: 'Masukkan nama produk...',
        onChanged: _productFormProvider.onChangedName,
      ),
    );
  }

  Widget price() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _priceController,
        labelText: 'Harga',
        hintText: 'Masukkan harga produk...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        prefixIcon: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Rp',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        onChanged: _productFormProvider.onChangedPrice,
      ),
    );
  }

  Widget stock() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _stockController,
        labelText: 'Stok',
        hintText: 'Masukkan stok produk...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: _productFormProvider.onChangedStock,
      ),
    );
  }

  Widget description() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: _descController,
        labelText: 'Deskripsi',
        hintText: 'Masukkan deskripsi produk...',
        maxLines: 4,
        onChanged: _productFormProvider.onChangedDesc,
      ),
    );
  }

  Widget createOrUpdateButton() {
    return Consumer<ProductFormProvider>(
      builder: (context, provider, _) {
        cl(provider.isFormValid());
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
          child: AppButton(
            text: widget.id == null ? 'Add Product' : 'Update Product',
            enabled: provider.isFormValid(),
            onTap: () {
              if (widget.id != null) {
                updatedProduct();
              } else {
                createProduct();
              }
            },
          ),
        );
      },
    );
  }

  Widget deleteButton() {
    if (widget.id == null) return const SizedBox(height: AppSizes.padding * 2);

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
            onTapRightButton: () async {
              AppDialog.closeDialog();
              deleteProduct();
            },
          );
        },
      ),
    );
  }

  void createProduct() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AppDialog.showDialogProgress();

    var res = await _productFormProvider.createProduct();

    AppDialog.closeDialog();

    if (res.isSuccess) {
      router.go('/products');
      messenger.showSnackBar(const SnackBar(content: Text('Product created')));
    } else {
      AppDialog.showErrorDialog(error: res.error?.message);
    }
  }

  void updatedProduct() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AppDialog.showDialogProgress();

    var res = await _productFormProvider.updatedProduct(widget.id!);

    AppDialog.closeDialog();

    if (res.isSuccess) {
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Product updated')));
    } else {
      AppDialog.showErrorDialog(error: res.error?.message);
    }
  }

  void deleteProduct() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AppDialog.showDialogProgress();

    var res = await _productFormProvider.deleteProduct(widget.id!);

    AppDialog.closeDialog();

    if (res.isSuccess) {
      router.go('/products');
      messenger.showSnackBar(const SnackBar(content: Text('Product deleted')));
    } else {
      AppDialog.showErrorDialog(error: res.error?.message);
    }
  }
}
