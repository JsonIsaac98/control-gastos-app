import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/gastos/presentation/pages/add_gasto_page.dart';
import '../../features/gastos/presentation/pages/dashboard_page.dart';
import '../../features/gastos/presentation/pages/gastos_list_page.dart';
import '../../features/gastos/presentation/pages/main_shell_page.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
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
