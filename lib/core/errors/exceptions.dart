import 'package:equatable/equatable.dart';

class APIException extends Equatable implements Exception {
  const APIException({this.error, this.code});

  final String? error;
  final int? code;

  @override
  List<Object?> get props => [error, code];
}

class CacheException extends Equatable implements Exception {
  const CacheException({this.error, this.code});

  final String? error;
  final int? code;

  @override
  List<Object?> get props => [error, code];
}

class ServiceException extends Equatable implements Exception {
  const ServiceException({this.error, this.code});

  final String? error;
  final int? code;

  @override
  List<Object?> get props => [error, code];
}
