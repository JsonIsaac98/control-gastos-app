/// Contrato de la capa de dominio para autenticación.
///
/// Intencionalmente sin referencias a Supabase para mantener
/// el dominio desacoplado de la infraestructura.
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña.
  /// Lanza [Exception] si las credenciales son inválidas.
  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con correo y contraseña.
  /// Lanza [Exception] si el correo ya está en uso.
  Future<void> signUp({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actualmente autenticado.
  Future<void> signOut();

  /// Actualiza la contraseña del usuario autenticado actualmente.
  /// Requiere sesión activa. Lanza [Exception] si falla.
  Future<void> changePassword({required String newPassword});

  /// Envía un email de recuperación/reseteo de contraseña al [email] dado.
  /// No requiere sesión activa.
  Future<void> sendPasswordReset({required String email});

  /// Retorna true si hay un usuario con sesión activa.
  bool get isAuthenticated;

  /// UID del usuario autenticado, o null si no hay sesión.
  String? get currentUserId;
}
