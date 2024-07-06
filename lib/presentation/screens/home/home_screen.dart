import 'package:flutter/material.dart';
import 'package:flutter_pos/app/const/dummy.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/screens/home/components/home_bottomsheet.dart';
import 'package:flutter_pos/presentation/screens/home/components/order_card.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';
import 'package:flutter_pos/presentation/widgets/products_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title(),
        actions: [
          syncButton(),
          networkInfo(),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1 / 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, i) {
          return productCard();
        },
      ),
      bottomNavigationBar: const HomeBottomsheet(),
    );
  }

  Widget title() {
    return Row(
      children: [
        AppImage(
          image: randomImage,
          borderRadius: 100,
          width: 34,
          height: 34,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        ),
        const SizedBox(width: AppSizes.padding / 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elriz Wiraswara',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 0,
                  ),
            ),
            Text(
              'elrizwiraswara@gmail.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        )
      ],
    );
  }

  Widget syncButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding / 4),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.sync,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Synced',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget networkInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Icon(
          Icons.wifi,
          size: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget productCard() {
    return ProductsCard(
      product: productDummy,
      onTap: () {
        AppDialog.show(
          title: 'Masukkan Jumlah',
          child: OrderCard(
            product: productDummy,
            showDeleteButton: false,
          ),
          rightButtonText: 'Tambah',
          leftButtonText: 'Batal',
          onTapLeftButton: () {
            GoRouter.of(context).pop();
          },
          onTapRightButton: () {
            GoRouter.of(context).pop();
          },
        );
      },
    );
  }
}
