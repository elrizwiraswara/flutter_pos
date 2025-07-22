import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageService({FirebaseStorage? firebaseStorage})
    : firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> uploadUserPhoto(String imgPath) async {
    final ref = firebaseStorage
        .ref()
        .child('user_photos')
        .child('UserImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putFile(File(imgPath), metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadProductImage(String imgPath) async {
    final ref = firebaseStorage
        .ref()
        .child('products')
        .child('ProductImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final taskSnapshot = await ref.putFile(File(imgPath), metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }
}
