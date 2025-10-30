import 'dart:convert';

import 'package:http/http.dart' show Response;

import '../utilities/console_logger.dart';

/// A generic result wrapper that encapsulates success/failure states
sealed class Result<T> {
  const Result();

  factory Result.success({
    String? title,
    String? message,
    String? state,
    required T data,
  }) = Success<T>;

  factory Result.failure({
    String? title,
    String? message,
    String? state,
    required Object error,
    StackTrace? stackTrace,
  }) = Failure<T>;

  /// Creates a Result from an HTTP response with proper error handling
  /// If parser is not provided, returns the raw response body as data
  factory Result.fromHttpResponse({
    required Response response,
    T Function(Map<String, dynamic>?)? parser,
  }) {
    try {
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        final T parsedData;

        if (parser != null) {
          parsedData = parser(
            response.body.isNotEmpty ? json.decode(response.body) as Map<String, dynamic>? : null,
          );
        } else {
          parsedData = response.body as T;
        }

        return Result.success(
          title: 'HTTP Success',
          message: response.reasonPhrase,
          state: response.statusCode.toString(),
          data: parsedData,
        );
      } else {
        return Result.failure(
          title: 'HTTP Error',
          message: response.reasonPhrase,
          state: response.statusCode.toString(),
          error: 'HTTP Error with status code: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      return Result.failure(
        title: 'Parse Error',
        message: 'Failed to parse response body with parser type of $T',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  String? get title => switch (this) {
    Success(title: final title) => title,
    Failure(title: final title) => title,
  };

  String? get message => switch (this) {
    Success(message: final message) => message,
    Failure(message: final message) => message,
  };

  String? get state => switch (this) {
    Success(state: final state) => state,
    Failure(state: final state) => state,
  };

  T? get data => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };

  Object? get error => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  R? onSuccess<R>(R Function(Success<T> success) success) => switch (this) {
    Success() => success(this as Success<T>),
    Failure() => null,
  };

  R? onFailure<R>(R Function(Failure<T> failure) failure) => switch (this) {
    Success() => null,
    Failure() => failure(this as Failure<T>),
  };

  R when<R>({
    required R Function(Success<T> success) success,
    required R Function(Failure<T> failure) failure,
  }) {
    return switch (this) {
      Success() => success(this as Success<T>),
      Failure() => failure(this as Failure<T>),
    };
  }
}

final class Success<T> extends Result<T> {
  @override
  final String? title;
  @override
  final String? message;
  @override
  final String? state;
  @override
  final T data;

  Success({
    this.title,
    this.message,
    this.state,
    required this.data,
  });
}

final class Failure<T> extends Result<T> {
  @override
  final String? title;
  @override
  final String? message;
  @override
  final String? state;
  @override
  final Object error;
  final StackTrace? stackTrace;

  Failure({
    this.title,
    this.message,
    this.state,
    required this.error,
    this.stackTrace,
  }) {
    // Always log any error to console in debug mode
    ce(error, title: title, message: message, state: state);
  }
}
