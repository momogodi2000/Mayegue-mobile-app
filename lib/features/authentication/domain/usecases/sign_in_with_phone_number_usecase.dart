import '../repositories/auth_repository.dart';
import '../entities/auth_response_entity.dart';

class SignInWithPhoneNumberUsecase {
  final AuthRepository repository;
  SignInWithPhoneNumberUsecase(this.repository);

  Future<AuthResponseEntity> call(String phoneNumber) async {
    return await repository.signInWithPhoneNumber(phoneNumber);
  }
}
