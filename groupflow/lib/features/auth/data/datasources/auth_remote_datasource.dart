import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<AuthUserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed: no user returned.');
    }

    return AuthUserModel.fromSupabaseUser(user);
  }

  @override
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign up failed: no user returned.');
    }

    return AuthUserModel.fromSupabaseUser(user);
  }

  @override
  Future<void> signOut() => _supabase.auth.signOut();

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AuthUserModel.fromSupabaseUser(user);
  }
}