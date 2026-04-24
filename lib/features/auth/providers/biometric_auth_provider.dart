import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/biometric_auth_repository_impl.dart';
import '../domain/repositories/biometric_auth_repository.dart';

part 'biometric_auth_provider.g.dart';

// ----------------------------------------------------------------
// Repositorio biométrico — singleton durante toda la app.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
BiometricAuthRepository biometricAuthRepository(
    BiometricAuthRepositoryRef ref) {
  return BiometricAuthRepositoryImpl();
}

// ----------------------------------------------------------------
// ¿El dispositivo soporta biometría y tiene algún método enrolado?
// Se calcula una vez y se invalida cuando el usuario cambia ajustes
// del sistema (en la práctica se re-lee al reconstruir el UI).
// ----------------------------------------------------------------
@riverpod
Future<bool> biometricAvailable(BiometricAvailableRef ref) {
  return ref.watch(biometricAuthRepositoryProvider).isBiometricAvailable();
}

// ----------------------------------------------------------------
// ¿Hay un refresh token guardado en secure storage?
// Se usa en la LoginPage para decidir si mostrar el botón biométrico
// (de nada sirve mostrarlo si aún no hay credenciales para restaurar).
// ----------------------------------------------------------------
@riverpod
Future<bool> biometricHasStoredSession(BiometricHasStoredSessionRef ref) async {
  final token =
      await ref.watch(biometricAuthRepositoryProvider).readRefreshToken();
  return token != null && token.isNotEmpty;
}

// ----------------------------------------------------------------
// Toggle "biometría habilitada" controlado por el usuario en ajustes.
// Expone el valor actual + método `set(bool)` para escribirlo.
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
class BiometricEnabled extends _$BiometricEnabled {
  @override
  Future<bool> build() {
    return ref.watch(biometricAuthRepositoryProvider).isBiometricEnabled();
  }

  /// Cambia el toggle. Si se desactiva, también borra el refresh token
  /// guardado para que no quede sesión recuperable después de apagarlo.
  Future<void> set(bool value) async {
    final repo = ref.read(biometricAuthRepositoryProvider);
    await repo.setBiometricEnabled(value);
    if (!value) {
      await repo.clearRefreshToken();
    }
    ref.invalidateSelf();
    ref.invalidate(biometricHasStoredSessionProvider);
  }
}
