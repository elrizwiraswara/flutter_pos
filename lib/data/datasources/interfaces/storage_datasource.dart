import '../../../core/common/result.dart';

abstract class StorageDataSource {
  Future<Result<String>> uploadUserPhoto(String imgPath);

  Future<Result<String?>> uploadProductImage(String imgPath);
}
