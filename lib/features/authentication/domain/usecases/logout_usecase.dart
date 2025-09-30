import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Logout usecase
class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      await repository.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Échec de déconnexion'));
    }
  }
}
