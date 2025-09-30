import '../repositories/auth_repository.dart';
import '../entities/auth_response_entity.dart';

class VerifyPhoneNumberUsecase {
  final AuthRepository repository;
  VerifyPhoneNumberUsecase(this.repository);

  Future<AuthResponseEntity> call(String verificationId, String smsCode) async {
    return await repository.verifyPhoneNumber(verificationId, smsCode);
  }
}
