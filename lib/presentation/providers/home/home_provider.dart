import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/services/auth/sign_in_with_google.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:flutter_pos/core/errors/errors.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/ordered_product_entity.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/usecases/product_usecases.dart';
import 'package:flutter_pos/domain/usecases/transaction_usecases.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;
  final ProductRepository productRepository;

  HomeProvider({required this.transactionRepository, required this.productRepository});

  final panelController = PanelController();

  bool isPanelExpanded = false;

  List<ProductEntity>? allProducts;

  List<OrderedProductEntity> orderedProducts = [];
  int receivedAmount = 0;
  String selectedPaymentMethod = 'cash';
  String? customerName;
  String? description;

  void resetStates() {
    isPanelExpanded = false;
    allProducts = null;
    orderedProducts = [];
    receivedAmount = 0;
    selectedPaymentMethod = 'cash';
    customerName = null;
    description = null;
  }

  Future<void> getAllProducts() async {
    var res = await GetAllProductsUsecase(productRepository).call(AuthService().getAuthData()!.uid);

    if (res.isSuccess) {
      allProducts = res.data ?? [];
      notifyListeners();
    } else {
      throw res.error?.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createTransaction() async {
    try {
      var transaction = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        paymentMethod: selectedPaymentMethod,
        customerName: customerName,
        description: description,
        orderedProducts: orderedProducts,
        createdById: AuthService().getAuthData()!.uid,
        receivedAmount: receivedAmount,
        returnAmount: receivedAmount - getTotalAmount(),
        totalAmount: getTotalAmount(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      var res = await CreateTransaction(transactionRepository).call(transaction);

      resetStates();
      panelController.close();

      // Refresh
      getAllProducts();

      return res;
    } catch (e) {
      cl('[createTransaction].error $e');
      return Result.error(APIError(error: e.toString()));
    }
  }

  void onChangedIsPanelExpanded(bool val) {
    isPanelExpanded = val;
    notifyListeners();
  }

  void onAddOrderedProduct(ProductEntity product, int qty) {
    if (orderedProducts.where((e) => e.productId == product.id).isNotEmpty) {
      orderedProducts.firstWhere((e) => e.productId == product.id).quantity = qty;
    } else {
      var order = OrderedProductEntity(quantity: qty, product: product, productId: product.id!);
      orderedProducts.add(order);
    }

    notifyListeners();
  }

  void onRemoveOrderedProduct(OrderedProductEntity val) {
    orderedProducts.remove(val);
    notifyListeners();
  }

  void onRemoveAllOrderedProduct() {
    orderedProducts.clear();
    panelController.close();
    isPanelExpanded = false;
    notifyListeners();
  }

  void onChangedOrderedProductQuantity(int index, int value) {
    orderedProducts[index].quantity = value;
    notifyListeners();
  }

  void onChangedReceivedAmount(int value) {
    receivedAmount = value;
    notifyListeners();
  }

  int getTotalAmount() {
    if (orderedProducts.isEmpty) return 0;
    return orderedProducts.map((e) => (e.product?.price ?? 0) * e.quantity).reduce((a, b) => a + b);
  }
}
