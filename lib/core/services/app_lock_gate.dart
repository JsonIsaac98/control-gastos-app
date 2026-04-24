import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/biometric_auth_provider.dart';
import 'local_auth_cache.dart';

/// Tiempo en background después del cual se vuelve a pedir biometría.
/// Por debajo de esto (ej. cambiar 2s a Safari) no se bloquea.
const Duration _kRelockAfter = Duration(seconds: 30);

/// Envuelve al router y muestra un overlay opaco cuando la app está
/// bloqueada por biometría.
///
/// Reglas:
///   • Si el usuario NO tiene biometría habilitada, nunca bloquea.
///   • Si no hay sesión (ni Supabase ni LocalAuthCache), nunca bloquea
///     (la /login es pública).
///   • En cold start: pide biometría antes de mostrar la UI.
///   • Al volver del background tras más de [_kRelockAfter], re-bloquea.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = true;
  bool _authenticating = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Intentar auto-desbloquear en el primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock(auto: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final bg = _backgroundedAt;
      if (bg != null && DateTime.now().difference(bg) >= _kRelockAfter) {
        if (mounted && _shouldLock()) {
          setState(() => _locked = true);
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _tryUnlock(auto: true));
        }
      }
      _backgroundedAt = null;
    }
  }

  bool _shouldLock() {
    if (!LocalAuthCache.instance.isLoggedIn) return false;
    final enabled = ref.read(biometricEnabledProvider).value ?? false;
    final available = ref.read(biometricAvailableProvider).value ?? false;
    return enabled && available;
  }

  Future<void> _tryUnlock({bool auto = false}) async {
    if (_authenticating) return;
    if (!_shouldLock()) {
      if (_locked) setState(() => _locked = false);
      return;
    }
    _authenticating = true;
    try {
      final repo = ref.read(biometricAuthRepositoryProvider);
      final ok = await repo.authenticate(
        reason: 'Desbloquea Gastos Personal',
      );
      if (!mounted) return;
      if (ok) setState(() => _locked = false);
    } finally {
      _authenticating = false;
    }
  }

  Future<void> _signOutFromLock() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    // Si no debe bloquear (no hay sesión o biometría apagada), mostrar child.
    final shouldLock = _shouldLock();
    if (!shouldLock && _locked) {
      _locked = false;
    }

    return Stack(
      children: [
        widget.child,
        if (_locked && shouldLock)
          Positioned.fill(
            child: _LockOverlay(
              onUnlock: () => _tryUnlock(),
              onSignOut: _signOutFromLock,
            ),
          ),
      ],
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay({required this.onUnlock, required this.onSignOut});

  final VoidCallback onUnlock;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _biometricIcon(),
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Gastos Personal',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Desbloquea con ${_biometricLabel()} para continuar',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onUnlock,
                icon: Icon(_biometricIcon()),
                label: const Text('Desbloquear'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSignOut,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _biometricIcon() {
    if (kIsWeb) return Icons.fingerprint;
    return Platform.isIOS ? Icons.face_outlined : Icons.fingerprint;
  }

  String _biometricLabel() {
    if (kIsWeb) return 'biometría';
    return Platform.isIOS ? 'Face ID' : 'huella';
  }
}
