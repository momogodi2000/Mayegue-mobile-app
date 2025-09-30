import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Get current user usecase
class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    try {
      final user = await repository.getCurrentUser();
      return Right(user);
    } catch (e) {
      return const Left(AuthFailure('Échec de récupération de l\'utilisateur'));
    }
  }
}
