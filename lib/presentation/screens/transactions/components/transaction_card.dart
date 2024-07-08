// import 'package:flutter/material.dart';
// import 'package:flutter_pos/domain/entities/transaction_entity.dart';

// import '../../../../../app/const/app_const.dart';
// import '../../../../../app/model/order/order_model.dart';
// import '../../../../../app/service/locator/locator.dart';
// import '../../../../../app/theme/app_assets.dart';
// import '../../../../../app/theme/app_colors.dart';
// import '../../../../../app/theme/app_text_style.dart';
// import '../../../../../app/utility/currency_formatter.dart';
// import '../../../../../app/utility/date_formatter.dart';
// import '../../../../../app/widgets/app_fluent_button.dart';
// import '../../../../../app/widgets/app_image.dart';
// import '../../../../../view_model/transaction/user_transaction_view_model.dart';

// class TransactionCard extends StatefulWidget {
//   final TransactionEntity transaction;
//   const TransactionCard({super.key, required this.transaction});

//   @override
//   State<TransactionCard> createState() => _TransactionCardState();
// }

// class _TransactionCardState extends State<TransactionCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Material(
//         child: InkWell(
//           onTap: () async {
//             final transactionViewModel = locator<UserTransactionViewModel>();

//             await Navigator.pushNamed(
//               context,
//               'order_detail',
//               arguments: widget.order.id,
//             );

//             transactionViewModel.getUserOrders();
//           },
//           splashColor: Colors.black.withOpacity(0.06),
//           splashFactory: InkRipple.splashFactory,
//           highlightColor: Colors.black12,
//           borderRadius: BorderRadius.circular(4),
//           child: Ink(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 width: 0.5,
//                 color: AppColors.blackLv3,
//               ),
//             ),
//             child: Column(
//               children: [
//                 head(),
//                 body(),
//                 footer(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget head() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             const Icon(
//               Icons.receipt_long_rounded,
//               size: 18,
//             ),
//             const SizedBox(width: 6),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.order.id ?? '',
//                   style: AppTextStyle.bold(size: 10),
//                 ),
//                 Text(
//                   DateFormatter.normalWithClock(widget.order.createdAt!),
//                   style: AppTextStyle.semibold(size: 8),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         AppFluentButton(
//           text: orderStatusName(
//             widget.order.orderStatus?.status,
//             widget.order.transactionMethod,
//           ),
//           color: orderStatusColor(
//             widget.order.orderStatus?.status,
//             widget.order.transactionMethod,
//           ),
//         )
//       ],
//     );
//   }

//   Widget body() {
//     return Column(
//       children: [
//         const Divider(height: 24),
//         Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 76,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       widget.order.orderedProduct?.first.name ?? '',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTextStyle.medium(size: 12),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               CurrencyFormatter.format(
//                                 widget.order.orderedProduct?.first.price ?? 0,
//                               ),
//                               style: AppTextStyle.bold(size: 12),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '/barang',
//                               style: AppTextStyle.medium(
//                                 size: 10,
//                                 color: AppColors.blackLv2,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Jumlah: ${widget.order.orderedProduct?.first.quantity}',
//                           style: AppTextStyle.medium(size: 12),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Container(
//               width: 76,
//               height: 76,
//               color: AppColors.blackLv5,
//               child: widget.order.orderedProduct?.first.imageUrl != null
//                   ? AppImage(
//                       image: widget.order.orderedProduct!.first.imageUrl!,
//                     )
//                   : const AppImage(
//                       image: AppAssets.emptyPlaceholder,
//                       imgProvider: ImgProvider.assetImage,
//                     ),
//             )
//           ],
//         ),
//       ],
//     );
//   }

//   Widget footer() {
//     if (widget.order.orderedProduct!.length == 1) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Divider(height: 24),
//         Text(
//           'dan 1 product lainnya',
//           style: AppTextStyle.bold(
//             size: 8,
//             color: AppColors.blackLv2,
//           ),
//         ),
//       ],
//     );
//   }
// }
