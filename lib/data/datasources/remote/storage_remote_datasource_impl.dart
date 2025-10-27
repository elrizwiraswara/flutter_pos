import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/common/result.dart';
import '../interfaces/storage_datasource.dart';

class StorageRemoteDataSourceImpl implements StorageDataSource {
  final FirebaseStorage _firebaseStorage;

  StorageRemoteDataSourceImpl(this._firebaseStorage);

  @override
  Future<Result<String>> uploadUserPhoto(String imgPath) async {
    final ref = _firebaseStorage
        .ref()
        .child('user_photos')
        .child('UserImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putFile(File(imgPath), metadata);

    final url = await taskSnapshot.ref.getDownloadURL();

    return Result.success(data: url);
  }

  @override
  Future<Result<String>> uploadProductImage(String imgPath) async {
    final ref = _firebaseStorage
        .ref()
        .child('products')
        .child('ProductImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putFile(File(imgPath), metadata);

    final url = await taskSnapshot.ref.getDownloadURL();

    return Result.success(data: url);
  }
}
