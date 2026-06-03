import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_respository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../viewmodel/auth_viewmodel.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ---------------------------------------------------------------------------
// Data layer
// ---------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(
    ref.watch(supabaseClientProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  ),
);

// ---------------------------------------------------------------------------
// Domain — Use Cases
// ---------------------------------------------------------------------------

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(
    ref.watch(authRepositoryProvider),
  ),
);

// ---------------------------------------------------------------------------
// Presentation — ViewModel
// ---------------------------------------------------------------------------

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    signInUseCase: ref.watch(signInUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
  ),
);