import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/services/firebase_storage/firebase_storage_service.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';
import 'package:flutter_pos/domain/usecases/user_usecases.dart';

class AccountProvider extends ChangeNotifier {
  final UserRepository userRepository;

  AccountProvider({required this.userRepository});

  File? imageFile;
  String? imageUrl;
  String? name;
  String? email;
  String? phone;

  void clearStates() {
    imageFile = null;
    imageUrl = null;
    name = null;
  }

  Future<UserEntity?> getUserDetail(String id) async {
    var res = await GetUserUsecase(userRepository).call(id);

    if (res.isSuccess) {
      return res.data;
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<String?> updatedUser(String id) async {
    try {
      if (imageFile != null) {
        imageUrl = await FirebaseStorageService().uploadProductImage(imageFile!.path);
      }

      cl('[updatedUser].imageUrl $imageUrl');

      var product = UserEntity(
        id: id,
        email: email,
        phone: phone,
        name: name!,
        imageUrl: imageUrl ?? '',
      );

      await UpateUserUsecase(userRepository).call(product);

      return null;
    } catch (e) {
      cl("[updatedUser].error $e");
      return e.toString();
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
