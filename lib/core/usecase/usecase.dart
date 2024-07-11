import '../errors/errors.dart';

abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

class Result<T> {
  final T? data;
  final ErrorBase? error;

  Result._({this.data, this.error});

  factory Result.success(T? data) => Result._(data: data);

  factory Result.error(ErrorBase? error) => Result._(error: error);

  bool get isSuccess => error == null;

  bool get isHasError => !isSuccess;
}
