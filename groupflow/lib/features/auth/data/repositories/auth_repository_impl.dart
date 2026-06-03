import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_respository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final model = await _dataSource.signIn(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final model = await _dataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<AuthUser?> getCurrentUser() async {
    final model = await _dataSource.getCurrentUser();
    return model?.toEntity();
  }
}