import 'package:flutter_pos/app/const/app_const.dart';

import '../../../../core/common/result.dart';
import '../../app/services/connectivity/ping_service.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/remote/storage_remote_datasource_impl.dart';

class StorageRepositoryImpl implements StorageRepository {
  final PingService pingService;
  final StorageRemoteDataSourceImpl storageRemoteDataSource;

  StorageRepositoryImpl({
    required this.pingService,
    required this.storageRemoteDataSource,
  });

  @override
  Future<Result<String>> uploadUserPhoto(String imgPath) async {
    try {
      if (!pingService.isConnected) return Result.failure(error: AppConst.noInternetMessage);

      final res = await storageRemoteDataSource.uploadUserPhoto(imgPath);
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> uploadProductImage(String imgPath) async {
    try {
      if (!pingService.isConnected) return Result.failure(error: AppConst.noInternetMessage);

      final res = await storageRemoteDataSource.uploadProductImage(imgPath);
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
