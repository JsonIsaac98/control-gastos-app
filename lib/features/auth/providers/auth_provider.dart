import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// ----------------------------------------------------------------
// Repositorio de autenticación
// keepAlive: true — vive durante toda la sesión de la app.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
}

// ----------------------------------------------------------------
// Stream de cambios de estado de autenticación
// Emite un evento cada vez que el usuario inicia o cierra sesión.
// keepAlive: true — la suscripción no debe cancelarse.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
}

// ----------------------------------------------------------------
// Notifier para operaciones de autenticación (Sign In / Up / Out)
// Expone un AsyncValue<void> que la UI puede observar para
// mostrar loading, errores o éxito.
// ----------------------------------------------------------------
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Inicia sesión con correo y contraseña.
  /// Retorna true si fue exitoso.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ),
    );
    return !state.hasError;
  }

  /// Registra un nuevo usuario con correo y contraseña.
  /// Retorna true si fue exitoso.
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
          ),
    );
    return !state.hasError;
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
