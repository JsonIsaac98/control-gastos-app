import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_auth_cache.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/biometric_auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = LocalAuthCache.instance.email ?? '—';
    final colorScheme = Theme.of(context).colorScheme;
    final biometricAvailable =
        ref.watch(biometricAvailableProvider).value ?? false;
    final biometricEnabled =
        ref.watch(biometricEnabledProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // ── Perfil ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'MI PERFIL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.person_outline,
                  color: colorScheme.onPrimaryContainer),
            ),
            title: const Text('Correo electrónico'),
            subtitle: Text(email),
          ),

          const Divider(),

          // ── Seguridad ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'SEGURIDAD',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Cambiar contraseña'),
            subtitle: const Text('Actualiza tu contraseña actual'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _mostrarDialogoCambiarPassword(context, ref),
          ),
          if (biometricAvailable)
            SwitchListTile(
              secondary: Icon(_biometricIcon()),
              title: Text(_biometricTitle()),
              subtitle: const Text(
                  'Inicia sesión y desbloquea la app con biometría'),
              value: biometricEnabled,
              onChanged: (value) =>
                  _toggleBiometric(context, ref, value),
            ),
          // ListTile(
          //   leading: const Icon(Icons.email_outlined),
          //   title: const Text('Recuperar contraseña'),
          //   subtitle: const Text('Recibe un enlace de restablecimiento'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () => _enviarRecuperacion(context, ref, email),
          // ),

          const Divider(),

          // ── Personalización ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'PERSONALIZACIÓN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorías'),
            subtitle: const Text('Crear y editar categorías personalizadas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categorias'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: const Text('Tarjetas de crédito'),
            subtitle: const Text('Gestionar tarjetas y días de corte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/tarjetas'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Presupuestos'),
            subtitle: const Text('Gestionar presupuestos mensuales'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/presupuestos'),
          ),

          const Divider(),

          // ── Acerca de ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'ACERCA DE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Gastos Personal'),
            subtitle: Text('Versión 1.0.0'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Diálogo: Cambiar contraseña
  // ----------------------------------------------------------------
  Future<void> _mostrarDialogoCambiarPassword(
      BuildContext context, WidgetRef ref) async {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa la nueva contraseña';
                    }
                    if (v.trim().length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Confirma la contraseña';
                    }
                    if (v.trim() != newPassCtrl.text.trim()) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop();

                try {
                  await ref
                      .read(authRepositoryProvider)
                      .changePassword(newPassword: newPassCtrl.text.trim());

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Contraseña actualizada correctamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );

    newPassCtrl.dispose();
    confirmCtrl.dispose();
  }

  // ----------------------------------------------------------------
  // Toggle biometría
  // ----------------------------------------------------------------
  IconData _biometricIcon() {
    if (kIsWeb) return Icons.fingerprint;
    return Platform.isIOS ? Icons.face_outlined : Icons.fingerprint;
  }

  String _biometricTitle() {
    if (kIsWeb) return 'Autenticación biométrica';
    return Platform.isIOS ? 'Face ID' : 'Huella digital';
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final repo = ref.read(biometricAuthRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    if (value) {
      // Activar → confirmar con biometría y guardar refresh token actual.
      final ok = await repo.authenticate(
        reason: 'Confirma tu identidad para habilitar biometría',
      );
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Autenticación cancelada.'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.refreshToken;
      if (token == null || token.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
                'No hay sesión activa. Inicia sesión con tu contraseña primero.'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await repo.saveRefreshToken(token);
      await repo.setBiometricEnabled(true);
      ref.invalidate(biometricEnabledProvider);
      ref.invalidate(biometricHasStoredSessionProvider);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Biometría habilitada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Desactivar → limpiar credencial y apagar flag.
      await ref.read(biometricEnabledProvider.notifier).set(false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Biometría deshabilitada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  // Enviar correo de recuperación
  // ----------------------------------------------------------------
  Future<void> _enviarRecuperacion(
      BuildContext context, WidgetRef ref, String email) async {
    // Confirmar antes de enviar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Text(
          'Se enviará un enlace de restablecimiento a:\n\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email: email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📧 Correo enviado a $email. Revisa tu bandeja.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
