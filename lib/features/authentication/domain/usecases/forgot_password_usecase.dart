import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Parameters for forgot password
class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}

/// Forgot password usecase
class ForgotPasswordUsecase implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    try {
      await repository.sendPasswordResetEmail(params.email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Échec d\'envoi de l\'email de réinitialisation: ${e.toString()}'));
    }
  }
}
