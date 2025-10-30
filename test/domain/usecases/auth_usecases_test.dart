import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/auth_repository.dart';
import 'package:flutter_pos/domain/usecases/auth_usecases.dart';
import 'package:flutter_pos/domain/usecases/params/no_param.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<UserEntity?>>(Result<UserEntity?>.success(data: null));
    provideDummy<Result<UserEntity>>(
      Result<UserEntity>.success(
        data: UserEntity(
          id: 'user123',
          name: 'John Doe',
          email: 'john@example.com',
        ),
      ),
    );
    provideDummy<Result<void>>(Result<void>.success(data: null));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('SignInWithGoogleUsecase', () {
    late SignInWithGoogleUsecase usecase;

    setUp(() {
      usecase = SignInWithGoogleUsecase(mockAuthRepository);
    });

    test('should return user from repository on successful sign in', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final result = Result<UserEntity>.success(data: user);

      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      final result = Result<UserEntity>.failure(error: 'Sign in failed');

      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });

  group('SignOutUsecase', () {
    late SignOutUsecase usecase;

    setUp(() {
      usecase = SignOutUsecase(mockAuthRepository);
    });

    test('should return success from repository', () async {
      // arrange
      final result = Result<void>.success(data: null);

      when(mockAuthRepository.signOut()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      final result = Result<void>.failure(error: 'Sign out failed');

      when(mockAuthRepository.signOut()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });

  group('GetCurrentUserUsecase', () {
    late GetCurrentUserUsecase usecase;

    setUp(() {
      usecase = GetCurrentUserUsecase(mockAuthRepository);
    });

    test('should return current user from repository', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final result = Result<UserEntity?>.success(data: user);

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      final result = Result<UserEntity?>.failure(error: 'Failed to get user');

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
