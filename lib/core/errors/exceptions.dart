import 'package:equatable/equatable.dart';

class APIException extends Equatable implements Exception {
  const APIException({this.message, this.code});

  final String? message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

class CacheException extends Equatable implements Exception {
  const CacheException({this.message, this.code});

  final String? message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

class ServiceException extends Equatable implements Exception {
  const ServiceException({this.message, this.code});

  final String? message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

class UnknownException extends Equatable implements Exception {
  const UnknownException({this.message, this.code});

  final String? message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}
