import 'package:flutter_pos/core/services/connectivity/ping_service.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/core/constants/constants.dart';
import 'package:flutter_pos/data/datasources/remote/storage_remote_datasource_impl.dart';
import 'package:flutter_pos/data/repositories/storage_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'storage_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PingService,
  StorageRemoteDataSourceImpl,
])
void main() {
  late StorageRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockStorageRemoteDataSourceImpl mockStorageRemoteDataSource;

  setUp(() {
    mockPingService = MockPingService();
    mockStorageRemoteDataSource = MockStorageRemoteDataSourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<String>>(
      Result.success(data: ''),
    );

    repository = StorageRepositoryImpl(
      pingService: mockPingService,
      storageRemoteDataSource: mockStorageRemoteDataSource,
    );
  });

  group('uploadUserPhoto', () {
    const imgPath = '/path/to/user/photo.jpg';
    const uploadedUrl = 'https://storage.example.com/users/photo_123.jpg';

    test('uploads user photo successfully when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(imgPath),
      ).thenAnswer((_) async => Result.success(data: uploadedUrl));

      final result = await repository.uploadUserPhoto(imgPath);

      expect(result.isSuccess, true);
      expect(result.data, uploadedUrl);
      verify(mockPingService.isConnected).called(1);
      verify(mockStorageRemoteDataSource.uploadUserPhoto(imgPath)).called(1);
    });

    test('returns failure with no internet message when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final result = await repository.uploadUserPhoto(imgPath);

      expect(result.isFailure, true);
      expect(result.error, Constants.noInternetMessage);
      verify(mockPingService.isConnected).called(1);
      verifyNever(mockStorageRemoteDataSource.uploadUserPhoto(any));
    });

    test('returns failure when remote datasource fails', () async {
      const errorMessage = 'Upload failed: Invalid file format';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(imgPath),
      ).thenAnswer((_) async => Result.failure(error: errorMessage));

      final result = await repository.uploadUserPhoto(imgPath);

      expect(result.isFailure, true);
      expect(result.error, errorMessage);
      verify(mockStorageRemoteDataSource.uploadUserPhoto(imgPath)).called(1);
    });

    test('handles exception during upload', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockStorageRemoteDataSource.uploadUserPhoto(imgPath)).thenThrow(Exception('Network timeout'));

      final result = await repository.uploadUserPhoto(imgPath);

      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
    });

    test('handles empty image path', () async {
      const emptyPath = '';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(emptyPath),
      ).thenAnswer((_) async => Result.failure(error: 'Invalid path'));

      final result = await repository.uploadUserPhoto(emptyPath);

      expect(result.isFailure, true);
      verify(mockStorageRemoteDataSource.uploadUserPhoto(emptyPath)).called(1);
    });

    test('verifies correct method is called with correct parameter', () async {
      const specificPath = '/storage/emulated/0/user_avatar.png';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(specificPath),
      ).thenAnswer((_) async => Result.success(data: uploadedUrl));

      await repository.uploadUserPhoto(specificPath);

      verify(mockStorageRemoteDataSource.uploadUserPhoto(specificPath)).called(1);
      verifyNever(mockStorageRemoteDataSource.uploadProductImage(any));
    });
  });

  group('uploadProductImage', () {
    const imgPath = '/path/to/product/image.jpg';
    const uploadedUrl = 'https://storage.example.com/products/image_456.jpg';

    test('uploads product image successfully when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadProductImage(imgPath),
      ).thenAnswer((_) async => Result.success(data: uploadedUrl));

      final result = await repository.uploadProductImage(imgPath);

      expect(result.isSuccess, true);
      expect(result.data, uploadedUrl);
      verify(mockPingService.isConnected).called(1);
      verify(mockStorageRemoteDataSource.uploadProductImage(imgPath)).called(1);
    });

    test('returns failure with no internet message when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final result = await repository.uploadProductImage(imgPath);

      expect(result.isFailure, true);
      expect(result.error, Constants.noInternetMessage);
      verify(mockPingService.isConnected).called(1);
      verifyNever(mockStorageRemoteDataSource.uploadProductImage(any));
    });

    test('returns failure when remote datasource fails', () async {
      const errorMessage = 'Upload failed: File too large';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadProductImage(imgPath),
      ).thenAnswer((_) async => Result.failure(error: errorMessage));

      final result = await repository.uploadProductImage(imgPath);

      expect(result.isFailure, true);
      expect(result.error, errorMessage);
      verify(mockStorageRemoteDataSource.uploadProductImage(imgPath)).called(1);
    });

    test('handles exception during upload', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockStorageRemoteDataSource.uploadProductImage(imgPath)).thenThrow(Exception('Storage service unavailable'));

      final result = await repository.uploadProductImage(imgPath);

      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
    });

    test('handles null or invalid path gracefully', () async {
      const invalidPath = '';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadProductImage(invalidPath),
      ).thenAnswer((_) async => Result.failure(error: 'Path cannot be empty'));

      final result = await repository.uploadProductImage(invalidPath);

      expect(result.isFailure, true);
      verify(mockStorageRemoteDataSource.uploadProductImage(invalidPath)).called(1);
    });

    test('verifies correct method is called with correct parameter', () async {
      const specificPath = '/storage/emulated/0/product_photo.jpg';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadProductImage(specificPath),
      ).thenAnswer((_) async => Result.success(data: uploadedUrl));

      await repository.uploadProductImage(specificPath);

      verify(mockStorageRemoteDataSource.uploadProductImage(specificPath)).called(1);
      verifyNever(mockStorageRemoteDataSource.uploadUserPhoto(any));
    });

    test('handles different image formats', () async {
      const pngPath = '/path/to/product.png';
      const jpegPath = '/path/to/product.jpeg';
      const webpPath = '/path/to/product.webp';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadProductImage(any),
      ).thenAnswer((_) async => Result.success(data: uploadedUrl));

      final pngResult = await repository.uploadProductImage(pngPath);
      final jpegResult = await repository.uploadProductImage(jpegPath);
      final webpResult = await repository.uploadProductImage(webpPath);

      expect(pngResult.isSuccess, true);
      expect(jpegResult.isSuccess, true);
      expect(webpResult.isSuccess, true);
      verify(mockStorageRemoteDataSource.uploadProductImage(pngPath)).called(1);
      verify(mockStorageRemoteDataSource.uploadProductImage(jpegPath)).called(1);
      verify(mockStorageRemoteDataSource.uploadProductImage(webpPath)).called(1);
    });
  });

  group('uploadUserPhoto and uploadProductImage integration', () {
    test('maintains independence between user and product uploads', () async {
      const userPath = '/user/photo.jpg';
      const productPath = '/product/image.jpg';
      const userUrl = 'https://storage.example.com/users/photo.jpg';
      const productUrl = 'https://storage.example.com/products/image.jpg';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(userPath),
      ).thenAnswer((_) async => Result.success(data: userUrl));
      when(
        mockStorageRemoteDataSource.uploadProductImage(productPath),
      ).thenAnswer((_) async => Result.success(data: productUrl));

      final userResult = await repository.uploadUserPhoto(userPath);
      final productResult = await repository.uploadProductImage(productPath);

      expect(userResult.isSuccess, true);
      expect(userResult.data, userUrl);
      expect(productResult.isSuccess, true);
      expect(productResult.data, productUrl);

      verify(mockStorageRemoteDataSource.uploadUserPhoto(userPath)).called(1);
      verify(mockStorageRemoteDataSource.uploadProductImage(productPath)).called(1);
    });

    test('handles connection state changes between uploads', () async {
      const imgPath = '/path/to/image.jpg';

      // First upload succeeds
      when(mockPingService.isConnected).thenReturn(true);
      when(mockStorageRemoteDataSource.uploadUserPhoto(imgPath)).thenAnswer((_) async => Result.success(data: 'url1'));

      final result1 = await repository.uploadUserPhoto(imgPath);
      expect(result1.isSuccess, true);

      // Connection lost for second upload
      when(mockPingService.isConnected).thenReturn(false);

      final result2 = await repository.uploadProductImage(imgPath);
      expect(result2.isFailure, true);
      expect(result2.error, Constants.noInternetMessage);
    });
  });

  group('Error scenarios', () {
    test('handles concurrent upload failures', () async {
      const path1 = '/path1.jpg';
      const path2 = '/path2.jpg';

      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockStorageRemoteDataSource.uploadUserPhoto(path1),
      ).thenAnswer((_) async => Result.failure(error: 'Error 1'));
      when(
        mockStorageRemoteDataSource.uploadProductImage(path2),
      ).thenAnswer((_) async => Result.failure(error: 'Error 2'));

      final result1 = await repository.uploadUserPhoto(path1);
      final result2 = await repository.uploadProductImage(path2);

      expect(result1.isFailure, true);
      expect(result1.error, 'Error 1');
      expect(result2.isFailure, true);
      expect(result2.error, 'Error 2');
    });

    test('propagates specific error types correctly', () async {
      const imgPath = '/path/to/image.jpg';

      when(mockPingService.isConnected).thenReturn(true);
      when(mockStorageRemoteDataSource.uploadUserPhoto(imgPath)).thenThrow(FormatException('Invalid image format'));

      final result = await repository.uploadUserPhoto(imgPath);

      expect(result.isFailure, true);
      expect(result.error, isA<FormatException>());
    });
  });
}
