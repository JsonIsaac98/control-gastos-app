/// Contrato de la capa de dominio para autenticación biométrica.
///
/// Intencionalmente sin referencias a local_auth ni flutter_secure_storage
/// para mantener el dominio desacoplado de la infraestructura.
///
/// Responsabilidades:
///   • Verificar disponibilidad de hardware biométrico.
///   • Solicitar al usuario autenticarse con Face ID / huella.
///   • Persistir (de forma segura) el refresh token de Supabase para
///     permitir login rápido tras logout.
///   • Persistir el toggle "biometría habilitada" elegido por el usuario
///     en la pantalla de ajustes.
abstract class BiometricAuthRepository {
  /// true si el dispositivo tiene hardware biométrico **y** al menos una
  /// huella / cara enrolada. Si cualquiera de las dos falta, retorna false.
  Future<bool> isBiometricAvailable();

  /// Lanza el prompt nativo de Face ID / huella.
  /// Devuelve true si el usuario fue autenticado correctamente.
  /// Nunca lanza: cancelaciones y errores se mapean a false.
  Future<bool> authenticate({required String reason});

  /// Guarda el refresh token de Supabase en el almacenamiento seguro
  /// (Keychain en iOS / EncryptedSharedPreferences en Android).
  Future<void> saveRefreshToken(String token);

  /// Lee el refresh token previamente guardado.
  /// Devuelve null si nunca se guardó o fue borrado.
  Future<String?> readRefreshToken();

  /// Elimina el refresh token del almacenamiento seguro.
  Future<void> clearRefreshToken();

  /// true si el usuario activó biometría desde la pantalla de ajustes.
  Future<bool> isBiometricEnabled();

  /// Persiste el valor del toggle "biometría habilitada".
  Future<void> setBiometricEnabled(bool value);
}
