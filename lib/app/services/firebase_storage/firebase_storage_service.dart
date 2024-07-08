import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as storage;

class FirebaseStorageService {
  Future<String> uploadUserPhoto(String imgPath) async {
    storage.TaskSnapshot taskSnapshot;

    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child('user_photos')
        .child('UserImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = storage.SettableMetadata(
      contentType: 'image/jpeg',
    );

    taskSnapshot = await ref.putFile(File(imgPath), metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadProductImage(String imgPath) async {
    storage.TaskSnapshot taskSnapshot;

    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child('products')
        .child('ProductImage_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = storage.SettableMetadata(
      contentType: 'image/jpeg',
    );

    taskSnapshot = await ref.putFile(File(imgPath), metadata);

    return await taskSnapshot.ref.getDownloadURL();
  }
}
