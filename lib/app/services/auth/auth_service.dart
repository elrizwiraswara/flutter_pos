import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/auth/auth_base.dart';
import '../../../core/errors/errors.dart';
import '../../../core/usecase/usecase.dart';

class AuthService implements AuthBase {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  User? getAuthData() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<Result<UserCredential>> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      var result = await _firebaseAuth.signInWithCredential(credential);

      return Result.success(result);
    } catch (e) {
      return Result.error(ServiceError(message: e.toString()));
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
