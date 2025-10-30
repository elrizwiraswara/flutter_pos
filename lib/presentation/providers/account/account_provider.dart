import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart' hide AuthProvider;
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/storage_usecases.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../auth/auth_provider.dart';

class AccountProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final StorageRepository storageRepository;

  AccountProvider({
    required this.authProvider,
    required this.authRepository,
    required this.userRepository,
    required this.storageRepository,
  });

  File? imageFile;
  String? imageUrl;
  String? name;
  String? email;
  String? phone;

  bool isLoaded = false;

  void resetStates() {
    imageFile = null;
    imageUrl = null;
    name = null;
    email = null;
    phone = null;
    isLoaded = false;
  }

  Future<void> initProfileForm() async {
    var userId = authProvider.user?.id;
    if (userId == null) throw 'Unathenticated!';

    var res = await GetUserUsecase(userRepository).call(userId);

    if (res.isSuccess) {
      imageUrl = res.data?.imageUrl;
      name = res.data?.name;
      email = res.data?.email;
      phone = res.data?.phone;

      isLoaded = true;
      notifyListeners();
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<void>> updatedUser() async {
    try {
      var userId = authProvider.user?.id;
      if (userId == null) throw 'Unathenticated!';

      if (imageFile != null) {
        final res = await UploadUserPhotoUsecase(storageRepository).call(imageFile!.path);
        imageUrl = res.data;
      }

      var product = UserEntity(
        id: userId,
        email: email,
        phone: phone,
        name: name!,
        imageUrl: imageUrl ?? '',
      );

      var res = await UpateUserUsecase(userRepository).call(product);

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedImage(File value) {
    imageFile = value;
    notifyListeners();
  }

  void onChangedName(String value) {
    name = value;
    notifyListeners();
  }

  void onChangedEmail(String value) {
    email = value;
    notifyListeners();
  }

  void onChangedPhone(String value) {
    phone = value;
    notifyListeners();
  }
}
