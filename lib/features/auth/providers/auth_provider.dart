import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../../core/services/local_auth_cache.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import 'biometric_auth_provider.dart';

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
  /// En caso de éxito guarda el userId + email en LocalAuthCache
  /// para que la app funcione offline en los próximos lanzamientos.
  /// Si la biometría está habilitada, también persiste el refresh token
  /// de Supabase en secure storage para permitir login biométrico luego.
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

    if (!state.hasError) {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        await LocalAuthCache.instance.saveUser(
          userId: userId,
          email: email,
        );
      }
      await _persistRefreshTokenIfBiometricEnabled();
    }

    return !state.hasError;
  }

  /// Registra un nuevo usuario con correo y contraseña.
  /// Retorna true si fue exitoso.
  /// En caso de éxito guarda el userId + email en LocalAuthCache.
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

    if (!state.hasError) {
      final userId =
          ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId != null) {
        await LocalAuthCache.instance.saveUser(
          userId: userId,
          email: email,
        );
      }
    }

    return !state.hasError;
  }

  /// Cierra la sesión actual.
  /// Borra LocalAuthCache siempre (incluso si Supabase falla sin internet)
  /// para que el router redirija a /login.
  /// Desactiva biometría y borra el refresh token: si otro usuario toma
  /// el teléfono y cierra sesión, su huella no queda habilitada para la
  /// cuenta siguiente.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    // Limpiar caché local independientemente del resultado de Supabase
    await LocalAuthCache.instance.clearUser();
    final biometric = ref.read(biometricAuthRepositoryProvider);
    await biometric.clearRefreshToken();
    await biometric.setBiometricEnabled(false);
    ref.invalidate(biometricEnabledProvider);
    ref.invalidate(biometricHasStoredSessionProvider);
  }

  /// Inicia sesión usando biometría + el refresh token guardado.
  /// Devuelve true si logró restaurar la sesión.
  ///
  /// Flujo:
  ///   1. Verificar que haya biometría disponible y habilitada.
  ///   2. Pedir autenticación biométrica al usuario.
  ///   3. Leer el refresh token de secure storage.
  ///   4. Llamar a Supabase.auth.setSession(refreshToken) para restaurar.
  ///   5. Si éxito, actualizar LocalAuthCache y re-guardar el nuevo
  ///      refresh token (Supabase lo rota en cada refresh).
  ///   6. Si falla (token revocado/expirado), limpiar credenciales y
  ///      apagar el toggle para que la UI caiga a email+password.
  Future<bool> signInWithBiometrics() async {
    final biometric = ref.read(biometricAuthRepositoryProvider);

    final available = await biometric.isBiometricAvailable();
    final enabled = await biometric.isBiometricEnabled();
    if (!available || !enabled) return false;

    final ok = await biometric.authenticate(
      reason: 'Autentícate para iniciar sesión',
    );
    if (!ok) return false;

    final refreshToken = await biometric.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    state = const AsyncValue.loading();
    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client.auth.setSession(refreshToken);

      final user = response.user ?? client.auth.currentUser;
      final session = response.session ?? client.auth.currentSession;
      if (user == null || session == null) {
        throw Exception('No se pudo restaurar la sesión.');
      }

      await LocalAuthCache.instance.saveUser(
        userId: user.id,
        email: user.email ?? LocalAuthCache.instance.email ?? '',
      );
      // Supabase rota el refresh token: guardar el nuevo.
      final newRefresh = session.refreshToken;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await biometric.saveRefreshToken(newRefresh);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      // Token revocado / expirado / sin internet: limpiar y forzar login manual.
      await biometric.clearRefreshToken();
      await biometric.setBiometricEnabled(false);
      ref.invalidate(biometricEnabledProvider);
      ref.invalidate(biometricHasStoredSessionProvider);
      state = AsyncValue.error(
        Exception('Sesión expirada. Inicia sesión con tu contraseña.'),
        st,
      );
      return false;
    }
  }

  /// Guarda el refresh token en secure storage si la biometría ya está
  /// habilitada. Se llama tras signIn exitoso para mantener sincronizado
  /// el token que se usará en futuros logins biométricos.
  Future<void> _persistRefreshTokenIfBiometricEnabled() async {
    final biometric = ref.read(biometricAuthRepositoryProvider);
    if (!await biometric.isBiometricEnabled()) return;
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    final token = session?.refreshToken;
    if (token != null && token.isNotEmpty) {
      await biometric.saveRefreshToken(token);
      ref.invalidate(biometricHasStoredSessionProvider);
    }
  }
}
