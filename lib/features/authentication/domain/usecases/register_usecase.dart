import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Register usecase
class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final result = await repository.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      return Right(result);
    } catch (e) {
      return const Left(AuthFailure('Échec d\'inscription'));
    }
  }
}
