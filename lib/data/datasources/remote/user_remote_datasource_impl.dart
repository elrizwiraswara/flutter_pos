import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserRemoteDatasourceImpl extends UserDatasource {
  final FirebaseFirestore _firebaseFirestore;

  UserRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<String> createUser(UserModel user) async {
    await _firebaseFirestore.collection('User').doc(user.id).set(user.toJson());
    // The id is uid from GoogleSignIn credential
    return user.id;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firebaseFirestore.collection('User').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firebaseFirestore.collection('User').doc(id).delete();
  }

  @override
  Future<UserModel?> getUser(String id) async {
    var res = await _firebaseFirestore.collection('User').where('id', isEqualTo: id).get();
    if (res.docs.isEmpty) return null;
    return UserModel.fromJson(res.docs.first.data());
  }
}
