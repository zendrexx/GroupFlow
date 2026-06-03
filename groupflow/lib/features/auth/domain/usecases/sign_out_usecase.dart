import '../repositories/auth_respository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute() => _repository.signOut();
}