import '../entities/auth_user.dart';
import '../repositories/auth_respository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}