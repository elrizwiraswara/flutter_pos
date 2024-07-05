import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LocalStorageKey {
  auth,
}

class StorageHelper {
  // This class is not meant to be instatiated or extended; this constructor
  // prevents instantiation and extension.
  StorageHelper._();

  static const _storage = FlutterSecureStorage();

  static Future<String?> readData(LocalStorageKey key) async {
    return await _storage.read(key: key.name);
  }

  static Future<Map<String, String>?> readAllData() async {
    return await _storage.readAll();
  }

  static Future<void> writeData(LocalStorageKey key, String value) async {
    return await _storage.write(key: key.name, value: value);
  }

  static Future<void> deleteData(LocalStorageKey key) async {
    return await _storage.delete(key: key.name);
  }

  static Future<void> deleteAllData() async {
    return await _storage.deleteAll();
  }
}
