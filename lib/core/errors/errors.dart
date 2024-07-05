import 'package:equatable/equatable.dart';

import 'exceptions.dart';

abstract class Error extends Equatable {
  final String? error;
  final int? code;

  const Error({this.error, this.code});

  String get errorerror => "$code Error $error";

  @override
  List<Object?> get props => [error, code];
}

class APIError extends Error {
  const APIError({super.error, super.code});

  APIError.fromException(APIException exception) : this(error: exception.error, code: exception.code);
}

class CacheError extends Error {
  const CacheError({super.error, super.code});

  CacheError.fromException(CacheException exception) : this(error: exception.error, code: exception.code);
}

class ServiceError extends Error {
  const ServiceError({super.error, super.code});

  ServiceError.fromException(ServiceException exception) : this(error: exception.error, code: exception.code);
}
