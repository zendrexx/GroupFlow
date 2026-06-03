import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  /// Returns the currently signed-in user, or null if not authenticated.
  Future<AuthUser?> getCurrentUser();
}