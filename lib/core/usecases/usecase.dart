import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base UseCase class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters usecase
class NoParams {
  const NoParams();
}
