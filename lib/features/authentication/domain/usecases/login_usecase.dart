import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Login usecase
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call(
    String email,
    String password,
  ) async {
    try {
      final result = await repository.signInWithEmailAndPassword(email, password);
      return Right(result);
    } catch (e) {
      return const Left(AuthFailure('Échec de connexion'));
    }
  }
}
