import 'package:equatable/equatable.dart';

import 'exceptions.dart';

abstract class ErrorBase extends Equatable {
  final String? message;
  final int? code;

  const ErrorBase({this.message, this.code});

  String get errorerror => "$code Error $message";

  @override
  List<Object?> get props => [message, code];
}

class APIError extends ErrorBase {
  const APIError({super.message, super.code});

  APIError.fromException(APIException exception) : this(message: exception.message, code: exception.code);
}

class CacheError extends ErrorBase {
  const CacheError({super.message, super.code});

  CacheError.fromException(CacheException exception) : this(message: exception.message, code: exception.code);
}

class ServiceError extends ErrorBase {
  const ServiceError({super.message, super.code});

  ServiceError.fromException(ServiceException exception) : this(message: exception.message, code: exception.code);
}

class UnknownError extends ErrorBase {
  const UnknownError({super.message, super.code});

  UnknownError.fromException(UnknownException exception) : this(message: exception.message, code: exception.code);
}
