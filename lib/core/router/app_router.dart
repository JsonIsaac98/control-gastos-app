import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/gastos/presentation/pages/add_gasto_page.dart';
import '../../features/gastos/presentation/pages/dashboard_page.dart';
import '../../features/gastos/presentation/pages/gastos_list_page.dart';
import '../../features/gastos/presentation/pages/main_shell_page.dart';
import '../providers/supabase_provider.dart';

part 'app_router.g.dart';

// ----------------------------------------------------------------
// ChangeNotifier que escucha cambios de autenticación de Supabase
// y notifica al GoRouter para que re-evalúe el redirect.
// ----------------------------------------------------------------
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(SupabaseClient client) {
    _subscription = client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ----------------------------------------------------------------
// Router principal con auth guard
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final client = ref.watch(supabaseClientProvider);

  // Conectar el ciclo de vida del notifier al del provider
  final notifier = _AuthChangeNotifier(client);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    // refreshListenable llama a redirect cada vez que el estado de auth cambia
    refreshListenable: notifier,

    // ── Auth Guard ──────────────────────────────────────────────
    redirect: (context, state) {
      final isAuthenticated = client.auth.currentUser != null;
      final location = state.matchedLocation;
      final isOnAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register');

      // No autenticado y fuera de rutas de auth → login
      if (!isAuthenticated && !isOnAuthRoute) return '/login';

      // Ya autenticado y en ruta de auth → dashboard
      if (isAuthenticated && isOnAuthRoute) return '/dashboard';

      // Sin cambio
      return null;
    },

    routes: [
      // ── Rutas de autenticación (públicas) ────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Rutas protegidas (requieren sesión) ──────────────────
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/historial',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GastosListPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/agregar',
        builder: (context, state) => const AddGastoPage(),
      ),
    ],
  );
}
