import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/repositories/storage_repository.dart';
import 'package:flutter_pos/domain/usecases/storage_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'storage_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([StorageRepository])
void main() {
  late MockStorageRepository mockStorageRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<String?>>(Result<String?>.success(data: null));
    provideDummy<Result<String>>(Result<String>.success(data: ''));
  });

  setUp(() {
    mockStorageRepository = MockStorageRepository();
  });

  group('UploadUserPhotoUsecase', () {
    late UploadUserPhotoUsecase usecase;

    setUp(() {
      usecase = UploadUserPhotoUsecase(mockStorageRepository);
    });

    test('should return uploaded photo URL from repository', () async {
      // arrange
      const imgPath = '/path/to/user/photo.jpg';
      const uploadedUrl = 'https://storage.example.com/users/photo.jpg';
      final result = Result<String>.success(data: uploadedUrl);

      when(mockStorageRepository.uploadUserPhoto(imgPath)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(imgPath);

      // assert
      expect(response, result);
      verify(mockStorageRepository.uploadUserPhoto(imgPath));
      verifyNoMoreInteractions(mockStorageRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      const imgPath = '/path/to/user/photo.jpg';
      final result = Result<String>.failure(error: 'Upload failed');

      when(mockStorageRepository.uploadUserPhoto(imgPath)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(imgPath);

      // assert
      expect(response, result);
      verify(mockStorageRepository.uploadUserPhoto(imgPath));
      verifyNoMoreInteractions(mockStorageRepository);
    });
  });

  group('UploadProductImageUsecase', () {
    late UploadProductImageUsecase usecase;

    setUp(() {
      usecase = UploadProductImageUsecase(mockStorageRepository);
    });

    test('should return uploaded image URL from repository', () async {
      // arrange
      const imgPath = '/path/to/product/image.jpg';
      const uploadedUrl = 'https://storage.example.com/products/image.jpg';
      final result = Result<String?>.success(data: uploadedUrl);

      when(mockStorageRepository.uploadProductImage(imgPath)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(imgPath);

      // assert
      expect(response, result);
      verify(mockStorageRepository.uploadProductImage(imgPath));
      verifyNoMoreInteractions(mockStorageRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      const imgPath = '/path/to/product/image.jpg';
      final result = Result<String?>.failure(error: 'Upload failed');

      when(mockStorageRepository.uploadProductImage(imgPath)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(imgPath);

      // assert
      expect(response, result);
      verify(mockStorageRepository.uploadProductImage(imgPath));
      verifyNoMoreInteractions(mockStorageRepository);
    });
  });
}
