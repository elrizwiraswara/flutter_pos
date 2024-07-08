import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';
import 'package:flutter_pos/domain/usecases/user_usecases.dart';

class MainProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;

  MainProvider({
    required this.transactionRepository,
    required this.userRepository,
    required this.productRepository,
  });

  bool isLoaded = false;

  Future<void> initMainProvider() async {
    await checkAndSaveUserData();
    await checkAndSaveUserProducts();
    await checkAndSaveUserTransactions();

    isLoaded = true;
    notifyListeners();
  }

  Future<void> checkAndSaveUserData() async {
    var auth = AuthService().getAuthData();

    if (auth == null) return;

    var res = await GetUserUsecase(userRepository).call(auth.uid);

    if (res.isSuccess && res.data == null) {
      var userEntity = UserEntity(
        id: auth.uid,
        name: auth.displayName,
        email: auth.email,
        phone: auth.phoneNumber,
        imageUrl: auth.photoURL,
      );

      await CreateUserUsecase(userRepository).call(userEntity);
    }
  }

  Future<void> checkAndSaveUserProducts() async {}

  Future<void> checkAndSaveUserTransactions() async {}
}
