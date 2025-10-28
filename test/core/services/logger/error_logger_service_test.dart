import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_pos/core/services/logger/error_logger_service.dart';
import 'package:flutter_pos/core/utilities/debug_mode_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'error_logger_service_test.mocks.dart';

@GenerateMocks([FirebaseCrashlytics, DebugModeWrapper])
void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late MockDebugModeWrapper mockDebugMode;
  late ErrorLoggerService errorLogger;

  group('ErrorLoggerService - Debug Mode Control', () {
    setUp(() {
      mockCrashlytics = MockFirebaseCrashlytics();
      mockDebugMode = MockDebugModeWrapper();
    });

    test('should NOT send to Crashlytics in debug mode', () {
      // Arrange
      when(mockDebugMode.isDebugMode).thenReturn(true);
      errorLogger = ErrorLoggerService(
        mockCrashlytics,
        debugMode: mockDebugMode,
      );
      final error = Exception('Test error');

      // Act
      errorLogger.log(error: error);

      // Assert
      verifyNever(mockCrashlytics.recordError(any, any));
    });

    test('should send to Crashlytics in release mode', () {
      // Arrange
      when(mockDebugMode.isDebugMode).thenReturn(false);
      errorLogger = ErrorLoggerService(
        mockCrashlytics,
        debugMode: mockDebugMode,
      );
      final error = Exception('Test error');

      // Act
      errorLogger.log(error: error);

      // Assert
      verify(mockCrashlytics.recordError(error, null)).called(1);
    });

    test('should send to Crashlytics in release mode with stackTrace', () {
      // Arrange
      when(mockDebugMode.isDebugMode).thenReturn(false);
      errorLogger = ErrorLoggerService(
        mockCrashlytics,
        debugMode: mockDebugMode,
      );
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act
      errorLogger.log(error: error, stackTrace: stackTrace);

      // Assert
      verify(mockCrashlytics.recordError(error, stackTrace)).called(1);
    });
  });
}
