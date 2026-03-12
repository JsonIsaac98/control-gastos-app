import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

/// Implementación de [AuthRepository] usando Supabase Auth.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  // ----------------------------------------------------------------
  // Sign In
  // ----------------------------------------------------------------
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      // Traducir errores comunes de Supabase al español
      throw Exception(_translateError(e.message));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  // ----------------------------------------------------------------
  // Sign Up
  // ----------------------------------------------------------------
  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      // Si Supabase requiere confirmación de email, session == null.
      // En ese caso informamos al usuario que revise su correo.
      if (response.session == null && response.user != null) {
        throw Exception(
          'Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.',
        );
      }
    } on AuthException catch (e) {
      throw Exception(_translateError(e.message));
    } catch (e) {
      // Re-lanzar excepciones propias (confirmación de email, etc.)
      rethrow;
    }
  }

  // ----------------------------------------------------------------
  // Sign Out
  // ----------------------------------------------------------------
  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(_translateError(e.message));
    }
  }

  // ----------------------------------------------------------------
  // Estado de sesión
  // ----------------------------------------------------------------
  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  // ----------------------------------------------------------------
  // Utilitario: traducción de errores de Supabase al español
  // ----------------------------------------------------------------
  String _translateError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return 'Este correo ya está registrado.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (lower.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (lower.contains('unable to validate email address')) {
      return 'El formato del correo no es válido.';
    }
    // Mensaje original si no hay traducción específica
    return message;
  }
}
