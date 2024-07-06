import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pos/domain/entities/category_entity.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';

class ProductFormProvider extends ChangeNotifier {
  File? imageFile;

  ProductEntity product = ProductEntity();

  Future<void> getProductDetail(int id) async {
    // TODO
  }

  void onChangedImage(File value) {
    imageFile = value;
    notifyListeners();
  }

  void onChangedName(String value) {
    product.name = value;
    notifyListeners();
  }

  void onChangedCatgeory(CategoryEntity value) {
    product.category = value;
    notifyListeners();
  }

  void onChangedPrice(String value) {
    product.price = int.tryParse(value);
    notifyListeners();
  }

  void onChangedStock(String value) {
    product.stock = int.tryParse(value);
    notifyListeners();
  }

  void onChangedDesc(String value) {
    product.description = value;
    notifyListeners();
  }
}
