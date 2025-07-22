import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  GoogleSignInClientAuthorization,
  GoogleSignInAuthorizationClient,
  User,
  UserCredential,
])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockGoogleSignInClientAuthorization mockGoogleSignInAuthorization;
  late MockGoogleSignInAuthorizationClient mockGoogleSignInAuthorizationClient;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockGoogleSignInAuthorization = MockGoogleSignInClientAuthorization();
    mockGoogleSignInAuthorizationClient = MockGoogleSignInAuthorizationClient();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    authService = AuthService(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );

    dotenv.testLoad(fileInput: 'client-id');
  });

  group('AuthService', () {
    test('isAuthenticated should return true when user is logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = await authService.isAuthenticated();

      expect(result, true);
    });

    test('isAuthenticated should return false when user is null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await authService.isAuthenticated();

      expect(result, false);
    });

    test('getAuthData should return current user', () {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = authService.getAuthData();

      expect(result, mockUser);
    });

    test('signIn should return success when Google sign-in is successful', () async {
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async => Future.value());

      when(mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleSignInAccount);

      when(mockGoogleSignInAccount.authentication).thenReturn(mockGoogleSignInAuthentication);

      when(mockGoogleSignInAccount.authorizationClient).thenReturn(mockGoogleSignInAuthorizationClient);

      when(
        mockGoogleSignInAuthorizationClient.authorizationForScopes(any),
      ).thenAnswer((_) async => mockGoogleSignInAuthorization);

      when(mockGoogleSignInAuthentication.idToken).thenReturn('id-token');
      when(mockGoogleSignInAuthorization.accessToken).thenReturn('access-token');

      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      final result = await authService.signIn();

      expect(result.isSuccess, true);
      expect(result.data, mockUserCredential);
    });

    test('signIn should return error when an exception occurs', () async {
      when(mockGoogleSignIn.authenticate()).thenThrow(Exception('Sign in failed'));

      final result = await authService.signIn();

      expect(result.isSuccess, false);
      expect(result.error?.message, 'Exception: Sign in failed');
    });

    test('signOut should return true when sign out succeeds', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {
        return;
      });
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {
        return;
      });

      final result = await authService.signOut();

      expect(result, true);
    });

    test('signOut should return false when an exception occurs', () async {
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out failed'));

      final result = await authService.signOut();

      expect(result, false);
    });
  });
}
