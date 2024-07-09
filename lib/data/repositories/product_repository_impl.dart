import 'dart:convert';

import '../../app/const/const.dart';
import '../../app/services/connectivity/connectivity_service.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/remote/product_remote_datasource_impl.dart';
import '../models/product_model.dart';
import '../models/queued_action_model.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDatasourceImpl productLocalDatasource;
  final ProductRemoteDatasourceImpl productRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasourceImpl;

  ProductRepositoryImpl({
    required this.productLocalDatasource,
    required this.productRemoteDatasource,
    required this.queuedActionLocalDatasourceImpl,
  });

  @override
  Future<Result<List<ProductEntity>>> getAllUserProducts(String userId) async {
    var local = await productLocalDatasource.getAllUserProduct(userId);

    if (ConnectivityService.isConnected) {
      var remote = await productRemoteDatasource.getAllUserProduct(userId);

      if (remote.isEmpty && local.isNotEmpty) {
        for (var data in local) {
          // Store local data to remote db
          await productRemoteDatasource.createProduct(data);
        }
        // Return local data
        return Result.success(local.map((e) => e.toEntity()).toList());
      }

      if (remote.isNotEmpty && local.isEmpty) {
        for (var data in remote) {
          // Store remote data to local db
          await productLocalDatasource.createProduct(data);
        }
        // Return remote data
        return Result.success(remote.map((e) => e.toEntity()).toList());
      }

      if (remote.isNotEmpty && local.isNotEmpty) {
        List<bool> isRemoteHasNewerData = [];

        for (var localData in local) {
          var matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

          if (matchRemoteData != null) {
            var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
            var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
            var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
            var isRemoteNewer = differenceInMinutes > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

            if (isRemoteNewer) {
              isRemoteHasNewerData.add(true);
              // Save remote data to local db
              await productLocalDatasource.updateProduct(matchRemoteData);
            } else {
              // Update remote with local data
              await productRemoteDatasource.updateProduct(localData);
            }
          } else {
            // No matching remote product, create it
            await productRemoteDatasource.createProduct(localData);
          }
        }

        if (isRemoteHasNewerData.contains(true)) {
          // Return remote data
          return Result.success(remote.map((e) => e.toEntity()).toList());
        } else {
          // Return local data
          return Result.success(local.map((e) => e.toEntity()).toList());
        }
      }
    }

    return Result.success(local.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<ProductEntity>> getProduct(int productId) async {
    var local = await productLocalDatasource.getProduct(productId);

    if (ConnectivityService.isConnected) {
      var remote = await productRemoteDatasource.getProduct(productId);

      if (remote == null && local != null) {
        // Store local data to remote db
        await productRemoteDatasource.createProduct(local);
        // Return local data
        return Result.success(local.toEntity());
      }

      if (remote != null && local == null) {
        // Store remote data to local db
        await productLocalDatasource.createProduct(remote);
        // Return remote data
        return Result.success(remote.toEntity());
      }

      if (remote != null && local != null) {
        var updatedAtLocal = DateTime.tryParse(local.updatedAt ?? DateTime.now().toIso8601String());
        var updatedAtRemote = DateTime.tryParse(remote.updatedAt ?? DateTime.now().toIso8601String());
        var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
        var isRemoteNewer = differenceInMinutes > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

        // Compare local & remote data updatedAt difference
        if (isRemoteNewer) {
          // Save remote data to local db
          await productLocalDatasource.updateProduct(remote);
          // Return remote data
          return Result.success(remote.toEntity());
        } else {
          // Store local data to remote db
          await productRemoteDatasource.updateProduct(local);
          // Return local data
          return Result.success(local.toEntity());
        }
      }
    }

    return Result.success(local?.toEntity());
  }

  @override
  Future<Result<int>> createProduct(ProductEntity product) async {
    var productId = await productLocalDatasource.createProduct(ProductModel.fromEntity(product));

    if (ConnectivityService.isConnected) {
      await productRemoteDatasource.createProduct(ProductModel.fromEntity(product)..id = productId);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'ProductRepositoryImpl',
          method: 'createProduct',
          param: jsonEncode((ProductModel.fromEntity(product)..id = productId).toJson()),
          isCritical: true,
        ),
      );
    }

    return Result.success(productId);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    await productLocalDatasource.deleteProduct(productId);

    if (ConnectivityService.isConnected) {
      await productRemoteDatasource.deleteProduct(productId);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'ProductRepositoryImpl',
          method: 'deleteProduct',
          param: productId.toString(),
          isCritical: true,
        ),
      );
    }
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    await productLocalDatasource.updateProduct(ProductModel.fromEntity(product));

    if (ConnectivityService.isConnected) {
      await productRemoteDatasource.updateProduct(ProductModel.fromEntity(product));
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'ProductRepositoryImpl',
          method: 'updateProduct',
          param: jsonEncode(ProductModel.fromEntity(product).toJson()),
          isCritical: true,
        ),
      );
    }
  }
}
