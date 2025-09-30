import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Reset password usecase
class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    try {
      await repository.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Échec d\'envoi de l\'email de réinitialisation'));
    }
  }
}
