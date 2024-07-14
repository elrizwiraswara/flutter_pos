import 'dart:convert';

import 'package:flutter_pos/core/errors/errors.dart';

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
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  ProductRepositoryImpl({
    required this.productLocalDatasource,
    required this.productRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserProducts(String userId) async {
    try {
      if (ConnectivityService.isConnected) {
        var local = await productLocalDatasource.getAllUserProducts(userId);
        var remote = await productRemoteDatasource.getAllUserProducts(userId);

        if (remote.isEmpty && local.isNotEmpty) {
          for (var data in local) {
            // Store local data to remote db
            await productRemoteDatasource.createProduct(data);
          }

          // Return synced data count
          return Result.success(local.length);
        }

        if (remote.isNotEmpty && local.isEmpty) {
          for (var data in remote) {
            // Store remote data to local db
            await productLocalDatasource.createProduct(data);
          }

          // Return synced data count
          return Result.success(remote.length);
        }

        int syncedDataCount = 0;

        if (remote.isNotEmpty && local.isNotEmpty) {
          // Local first
          for (var localData in local) {
            var matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

            if (matchRemoteData != null) {
              var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                syncedDataCount += 1;
                // Save remote data to local db
                await productLocalDatasource.updateProduct(matchRemoteData);
              }

              if (isLocalNewer) {
                syncedDataCount += 1;
                // Update remote with local data
                await productRemoteDatasource.updateProduct(localData);
              }
            } else {
              syncedDataCount += 1;
              // No matching remote product, create it
              await productRemoteDatasource.createProduct(localData);
            }
          }

          // Remote first
          for (var remoteData in remote) {
            var matchLocalData = local.where((localData) => localData.id == remoteData.id).firstOrNull;

            if (matchLocalData != null) {
              var updatedAtLocal = DateTime.tryParse(remoteData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchLocalData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                syncedDataCount += 1;
                // Save remote data to local db
                await productLocalDatasource.updateProduct(remoteData);
              }

              if (isLocalNewer) {
                syncedDataCount += 1;
                // Update remote with local data
                await productRemoteDatasource.updateProduct(matchLocalData);
              }
            } else {
              syncedDataCount += 1;
              // No matching remote product, create it
              await productLocalDatasource.createProduct(remoteData);
            }
          }
        }

        // Return synced data count
        return Result.success(syncedDataCount);
      }

      return Result.success(0);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var local = await productLocalDatasource.getUserProducts(
        userId,
        orderBy: orderBy,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
        contains: contains,
      );

      if (ConnectivityService.isConnected) {
        var remote = await productRemoteDatasource.getUserProducts(
          userId,
          orderBy: orderBy,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
          contains: contains,
        );

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

          // Return local data
          return Result.success(remote.map((e) => e.toEntity()).toList());
        }

        if (remote.isNotEmpty && local.isNotEmpty) {
          List<bool> isRemoteHasNewerData = [];

          // Local first only
          for (var localData in local) {
            var matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

            if (matchRemoteData != null) {
              // Compare local & remote data updatedAt difference
              var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                isRemoteHasNewerData.add(true);
                // Save remote data to local db
                await productLocalDatasource.updateProduct(matchRemoteData);
              }

              if (isLocalNewer) {
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
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> getProduct(int productId) async {
    try {
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
          // Check is the difference is above the minimum interval sync tolerance
          var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
          var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

          // Compare local & remote data updatedAt difference
          if (isRemoteNewer) {
            // Save remote data to local db
            await productLocalDatasource.updateProduct(remote);
            // Return remote data
            return Result.success(remote.toEntity());
          }

          if (isLocalNewer) {
            // Store local data to remote db
            await productRemoteDatasource.updateProduct(local);
            // Return local data
            return Result.success(local.toEntity());
          }
        }
      }

      return Result.success(local?.toEntity());
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> createProduct(ProductEntity product) async {
    try {
      var data = ProductModel.fromEntity(product);

      var productId = await productLocalDatasource.createProduct(data);

      if (ConnectivityService.isConnected) {
        await productRemoteDatasource.createProduct(data);
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'createProduct',
            param: jsonEncode((data).toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(productId);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(int productId) async {
    try {
      await productLocalDatasource.deleteProduct(productId);

      if (ConnectivityService.isConnected) {
        await productRemoteDatasource.deleteProduct(productId);
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'deleteProduct',
            param: productId.toString(),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductEntity product) async {
    try {
      await productLocalDatasource.updateProduct(ProductModel.fromEntity(product));

      if (ConnectivityService.isConnected) {
        await productRemoteDatasource.updateProduct(ProductModel.fromEntity(product));
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'updateProduct',
            param: jsonEncode(ProductModel.fromEntity(product).toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }
}
