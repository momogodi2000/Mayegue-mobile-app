import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

/// Facebook sign in usecase
class FacebookSignInUsecase implements UseCase<AuthResponseEntity, NoParams> {
  final AuthRepository repository;

  FacebookSignInUsecase(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(NoParams params) async {
    try {
      final result = await repository.signInWithFacebook();
      return Right(result);
    } catch (e) {
      return Left(AuthFailure('Échec de connexion avec Facebook: ${e.toString()}'));
    }
  }
}
