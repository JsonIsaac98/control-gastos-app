import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caché local de la identidad del usuario autenticado.
///
/// Guarda únicamente userId y email en SharedPreferences para que la app
/// pueda reconocer al usuario y funcionar offline DESPUÉS de que haya
/// iniciado sesión al menos una vez con conexión.
///
/// ⚠️  NUNCA almacena contraseñas ni tokens de acceso.
///     La seguridad del acceso a la nube sigue siendo responsabilidad
///     del token de Supabase (que se renueva automáticamente cuando
///     vuelve la conectividad).
///
/// Uso típico:
///   1. bootstrap()          → loadFromPrefs()
///   2. signIn exitoso       → saveUser(userId, email)
///   3. signOut              → clearUser()
///   4. Router / SyncService → isLoggedIn / userId
class LocalAuthCache extends ChangeNotifier {
  // Singleton — un único instancia en toda la app
  LocalAuthCache._();
  static final instance = LocalAuthCache._();

  String? _userId;
  String? _userEmail;

  static const _keyUserId = 'local_auth_user_id';
  static const _keyEmail = 'local_auth_email';

  // ── Getters ──────────────────────────────────────────────────
  /// true si hay un usuario cacheado (aunque Supabase no tenga sesión activa).
  bool get isLoggedIn => _userId != null;

  /// UID del usuario (mismo que Supabase userId).
  String? get userId => _userId;

  /// Email del usuario para mostrarlo en la UI.
  String? get email => _userEmail;

  // ── Carga inicial ─────────────────────────────────────────────
  /// Lee la caché de SharedPreferences.
  /// Se llama UNA VEZ en bootstrap() antes de runApp().
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_keyUserId);
    _userEmail = prefs.getString(_keyEmail);
    // No llamamos notifyListeners() aquí porque aún no hay widgets escuchando
  }

  // ── Escritura ─────────────────────────────────────────────────
  /// Persiste el usuario tras un login o registro exitoso.
  /// Notifica al router para re-evaluar el redirect inmediatamente.
  Future<void> saveUser({
    required String userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    _userId = userId;
    _userEmail = email;
    notifyListeners();
  }

  /// Elimina la caché tras un sign-out explícito del usuario.
  /// Notifica al router para redirigir a /login.
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }
}
