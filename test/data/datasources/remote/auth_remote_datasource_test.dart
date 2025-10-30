import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_pos/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([
  firebase_auth.FirebaseAuth,
  GoogleSignIn,
  firebase_auth.UserCredential,
  firebase_auth.User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  GoogleSignInAuthorizationClient,
  GoogleSignInClientAuthorization,
])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('signInWithGoogle', () {
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
    late MockGoogleSignInAuthorizationClient mockAuthorizationClient;
    late MockGoogleSignInClientAuthorization mockAccessTokenAuth;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUp(() {
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      mockAuthorizationClient = MockGoogleSignInAuthorizationClient();
      mockAccessTokenAuth = MockGoogleSignInClientAuthorization();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
    });

    test('successfully signs in with Google and returns UserModel', () async {
      // Arrange
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async => {});

      when(mockGoogleSignIn.attemptLightweightAuthentication()).thenAnswer((_) async => mockGoogleSignInAccount);

      when(mockGoogleSignInAccount.authentication).thenReturn(mockGoogleSignInAuthentication);

      when(mockGoogleSignInAccount.authorizationClient).thenReturn(mockAuthorizationClient);

      when(mockAuthorizationClient.authorizationForScopes(any)).thenAnswer((_) async => mockAccessTokenAuth);

      when(mockGoogleSignInAuthentication.idToken).thenReturn('test_id_token');
      when(mockAccessTokenAuth.accessToken).thenReturn('test_access_token');

      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);

      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUser.phoneNumber).thenReturn('123');

      // Act
      final result = await dataSource.signInWithGoogle();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<UserModel>());
      expect(result.data?.id, 'test_uid');
      expect(result.data?.email, 'test@example.com');
      expect(result.data?.phone, '123');

      verify(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).called(1);
      verify(mockGoogleSignIn.attemptLightweightAuthentication()).called(1);
      verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
    });

    test('returns failure when user is null after sign-in', () async {
      // Arrange
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async => {});

      when(mockGoogleSignIn.attemptLightweightAuthentication()).thenAnswer((_) async => mockGoogleSignInAccount);

      when(mockGoogleSignInAccount.authentication).thenReturn(mockGoogleSignInAuthentication);

      when(mockGoogleSignInAccount.authorizationClient).thenReturn(mockAuthorizationClient);

      when(mockAuthorizationClient.authorizationForScopes(any)).thenAnswer((_) async => mockAccessTokenAuth);

      when(mockGoogleSignInAuthentication.idToken).thenReturn('test_id_token');
      when(mockAccessTokenAuth.accessToken).thenReturn('test_access_token');

      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(null);

      // Act
      final result = await dataSource.signInWithGoogle();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'User data is null after sign-in.');
    });

    test('returns failure when Google sign-in throws exception', () async {
      // Arrange
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async => {});

      when(mockGoogleSignIn.attemptLightweightAuthentication()).thenThrow(Exception('Google sign-in failed'));

      // Act
      final result = await dataSource.signInWithGoogle();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
      expect(result.error.toString(), contains('Google sign-in failed'));
    });

    test('returns failure when Firebase authentication throws exception', () async {
      // Arrange
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async => {});

      when(mockGoogleSignIn.attemptLightweightAuthentication()).thenAnswer((_) async => mockGoogleSignInAccount);

      when(mockGoogleSignInAccount.authentication).thenReturn(mockGoogleSignInAuthentication);

      when(mockGoogleSignInAccount.authorizationClient).thenReturn(mockAuthorizationClient);

      when(mockAuthorizationClient.authorizationForScopes(any)).thenAnswer((_) async => mockAccessTokenAuth);

      when(mockGoogleSignInAuthentication.idToken).thenReturn('test_id_token');
      when(mockAccessTokenAuth.accessToken).thenReturn('test_access_token');

      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenThrow(firebase_auth.FirebaseAuthException(code: 'auth-error'));

      // Act
      final result = await dataSource.signInWithGoogle();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<firebase_auth.FirebaseAuthException>());
    });
  });

  group('signOut', () {
    test('successfully signs out from Firebase and Google', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});

      // Act
      final result = await dataSource.signOut();

      // Assert
      expect(result.isSuccess, true);
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('returns failure when Firebase sign-out throws exception', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Firebase sign-out failed'));

      // Act
      final result = await dataSource.signOut();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
      verify(mockFirebaseAuth.signOut()).called(1);
      verifyNever(mockGoogleSignIn.signOut());
    });

    test('returns failure when Google sign-out throws exception', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
      when(mockGoogleSignIn.signOut()).thenThrow(Exception('Google sign-out failed'));

      // Act
      final result = await dataSource.signOut();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });

  group('getCurrentUser', () {
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser();
    });

    test('returns UserModel when user is signed in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUser.phoneNumber).thenReturn('123');

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<UserModel>());
      expect(result.data?.id, 'test_uid');
      expect(result.data?.email, 'test@example.com');
      expect(result.data?.phone, '123');
    });

    test('returns null when no user is signed in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, null);
    });

    test('returns failure when getting current user throws exception', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenThrow(Exception('Failed to get current user'));

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
    });
  });
}
