import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_pos/data/datasources/remote/storage_remote_datasource_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StorageRemoteDataSourceImpl dataSource;
  late MockFirebaseStorage mockFirebaseStorage;

  setUp(() {
    mockFirebaseStorage = MockFirebaseStorage();
    dataSource = StorageRemoteDataSourceImpl(mockFirebaseStorage);
  });

  test('uploadUserPhoto uploads a file and returns a download URL', () async {
    final res = await dataSource.uploadUserPhoto('test_image.jpg');
    expect(res.data, isNotEmpty);
  });

  test('uploadProductImage uploads a file and returns a download URL', () async {
    final res = await dataSource.uploadProductImage('test_product.jpg');
    expect(res.data, isNotEmpty);
  });
}
