import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../repositories/storage_repository.dart';

class UploadUserPhotoUsecase extends Usecase<Result, String> {
  UploadUserPhotoUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<String?>> call(String imgPath) async => _storageRepository.uploadUserPhoto(imgPath);
}

class UploadProductImageUsecase extends Usecase<Result, String> {
  UploadProductImageUsecase(this._storageRepository);

  final StorageRepository _storageRepository;

  @override
  Future<Result<String?>> call(String imgPath) async => _storageRepository.uploadProductImage(imgPath);
}
