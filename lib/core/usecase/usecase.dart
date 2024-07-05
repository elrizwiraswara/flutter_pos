import 'package:equatable/equatable.dart';

import '../errors/errors.dart';

abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

class Result<T> {
  final T? data;
  final Error? error;

  Result._({this.data, this.error});

  factory Result.success(T? data) => Result._(data: data);

  factory Result.error(Error? error) => Result._(error: error);

  bool get isSuccess => error == null;

  bool get isHasError => !isSuccess;
}
