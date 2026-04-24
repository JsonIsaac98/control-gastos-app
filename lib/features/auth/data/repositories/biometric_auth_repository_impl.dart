import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/biometric_auth_repository.dart';

/// Implementación basada en:
///   • `local_auth`            — prompt nativo de Face ID / huella.
///   • `flutter_secure_storage` — Keychain (iOS) / EncryptedSharedPreferences (Android)
///     para guardar el refresh token sin exponerlo a SharedPreferences planos.
///   • `shared_preferences`    — flag booleano del toggle "biometría habilitada".
class BiometricAuthRepositoryImpl implements BiometricAuthRepository {
  BiometricAuthRepositoryImpl({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const _kRefreshTokenKey = 'biometric_refresh_token';
  static const _kEnabledKey = 'biometric_login_enabled';

  // ── Disponibilidad ─────────────────────────────────────────────────
  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Prompt de autenticación ────────────────────────────────────────
  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ── Refresh token (secure storage) ────────────────────────────────
  @override
  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: _kRefreshTokenKey, value: token);

  @override
  Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _kRefreshTokenKey);

  @override
  Future<void> clearRefreshToken() =>
      _secureStorage.delete(key: _kRefreshTokenKey);

  // ── Toggle "biometría habilitada" ─────────────────────────────────
  @override
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, value);
  }
}
