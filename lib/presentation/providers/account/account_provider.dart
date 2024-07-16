import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../app/services/firebase_storage/firebase_storage_service.dart';
import '../../../app/utilities/console_log.dart';
import '../../../core/errors/errors.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user_usecases.dart';

class AccountProvider extends ChangeNotifier {
  final UserRepository userRepository;

  AccountProvider({required this.userRepository});

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

  Future<void> initProfileForm(String id) async {
    var res = await GetUserUsecase(userRepository).call(id);

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

  Future<Result<void>> updatedUser(String id) async {
    try {
      if (imageFile != null) {
        imageUrl = await FirebaseStorageService().uploadUserPhoto(imageFile!.path);
      }

      cl('[updatedUser].imageUrl $imageUrl');

      var product = UserEntity(
        id: id,
        email: email,
        phone: phone,
        name: name!,
        imageUrl: imageUrl ?? '',
      );

      var res = await UpateUserUsecase(userRepository).call(product);

      return res;
    } catch (e) {
      cl("[updatedUser].error $e");
      return Result.error(UnknownError(message: e.toString()));
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
