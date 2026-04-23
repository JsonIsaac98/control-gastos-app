import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/gastos/presentation/pages/add_gasto_page.dart';
import '../../features/gastos/presentation/pages/cuotas_page.dart';
import '../../features/gastos/presentation/pages/dashboard_page.dart';
import '../../features/gastos/presentation/pages/gastos_list_page.dart';
import '../../features/gastos/presentation/pages/main_shell_page.dart';
import '../../features/presupuestos/presentation/pages/presupuestos_page.dart';
import '../../features/reportes/presentation/pages/reportes_page.dart';
import '../../features/settings/presentation/pages/categorias_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tarjetas/presentation/pages/tarjetas_settings_page.dart';
import '../providers/supabase_provider.dart';
import '../services/local_auth_cache.dart';

part 'app_router.g.dart';

// ----------------------------------------------------------------
// ChangeNotifier que escucha DOS fuentes:
//   1. Supabase auth  → sesión online (token JWT)
//   2. LocalAuthCache → sesión offline cacheada (userId + email)
//
// Cuando cualquiera de las dos cambia, GoRouter re-evalúa el redirect.
// ----------------------------------------------------------------
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(SupabaseClient client) {
    // Escuchar cambios en la sesión de Supabase (login / logout / token refresh)
    _subscription = client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
    // Escuchar cambios en la caché local (saveUser / clearUser)
    LocalAuthCache.instance.addListener(notifyListeners);
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    LocalAuthCache.instance.removeListener(notifyListeners);
    super.dispose();
  }
}

// ----------------------------------------------------------------
// Router principal con auth guard offline-ready
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final client = ref.watch(supabaseClientProvider);

  final notifier = _AuthChangeNotifier(client);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: notifier,

    // ── Auth Guard ──────────────────────────────────────────────
    // Consideramos autenticado si CUALQUIERA de los dos es verdadero:
    //   • Supabase tiene sesión activa (con internet)
    //   • LocalAuthCache tiene datos (sesión offline cacheada)
    redirect: (context, state) {
      final supabaseAuth = client.auth.currentUser != null;
      final localAuth = LocalAuthCache.instance.isLoggedIn;
      final isAuthenticated = supabaseAuth || localAuth;

      final location = state.matchedLocation;
      final isOnAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register');

      // No autenticado y fuera de rutas de auth → login
      if (!isAuthenticated && !isOnAuthRoute) return '/login';

      // Ya autenticado y en ruta de auth → dashboard
      if (isAuthenticated && isOnAuthRoute) return '/dashboard';

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
          GoRoute(
            path: '/reportes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportesPage(),
            ),
          ),
          GoRoute(
            path: '/cuotas',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CuotasPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/agregar',
        builder: (context, state) => const AddGastoPage(),
      ),
      GoRoute(
        path: '/presupuestos',
        builder: (context, state) => const PresupuestosPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/categorias',
        builder: (context, state) => const CategoriasSettingsPage(),
      ),
      GoRoute(
        path: '/settings/tarjetas',
        builder: (context, state) => const TarjetasSettingsPage(),
      ),
    ],
  );
}
