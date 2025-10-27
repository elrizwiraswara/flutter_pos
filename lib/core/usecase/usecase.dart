abstract class Usecase<Result, Params> {
  Future<Result> call(Params params);
}
