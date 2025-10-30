import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/common/result.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserRemoteDatasourceImpl extends UserDatasource {
  final FirebaseFirestore _firebaseFirestore;

  UserRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<Result<String>> createUser(UserModel user) async {
    try {
      await _firebaseFirestore.collection('User').doc(user.id).set(user.toJson());
      // The id is uid from GoogleSignIn credential
      return Result.success(data: user.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _firebaseFirestore.collection('User').doc(user.id).set(user.toJson(), SetOptions(merge: true));
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _firebaseFirestore.collection('User').doc(id).delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      var res = await _firebaseFirestore.collection('User').where('id', isEqualTo: id).get();
      if (res.docs.isEmpty) return Result.success(data: null);
      return Result.success(data: UserModel.fromJson(res.docs.first.data()));
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
