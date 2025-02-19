import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_pos/app/services/firebase_storage/firebase_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FirebaseStorageService firebaseStorageService;
  late MockFirebaseStorage mockStorage;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    firebaseStorageService = FirebaseStorageService(firebaseStorage: mockStorage);
  });

  test('uploadUserPhoto uploads a file and returns a download URL', () async {
    final url = await firebaseStorageService.uploadUserPhoto('test_image.jpg');
    expect(url, isNotEmpty);
  });

  test('uploadProductImage uploads a file and returns a download URL', () async {
    final url = await firebaseStorageService.uploadProductImage('test_product.jpg');
    expect(url, isNotEmpty);
  });
}
