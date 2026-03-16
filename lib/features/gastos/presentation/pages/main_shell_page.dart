import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/sync_provider.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final int currentIndex;
    if (location.startsWith('/historial')) {
      currentIndex = 1;
    } else if (location.startsWith('/reportes')) {
      currentIndex = 2;
    } else {
      currentIndex = 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
            case 1:
              context.go('/historial');
            case 2:
              context.go('/reportes');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_settings',
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
            child: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_nuevo_gasto',
            onPressed: () => context.push('/agregar'),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Gasto'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ----------------------------------------------------------------
// ThemeToggleButton — cicla entre system / light / dark
// ----------------------------------------------------------------
/// Botón reutilizable para el toggle del tema.
/// Se agrega en el actions de cualquier AppBar.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeNotifierProvider);

    final (icon, tooltip) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto, 'Automático (sistema)'),
      ThemeMode.light => (Icons.light_mode, 'Modo claro'),
      ThemeMode.dark => (Icons.dark_mode, 'Modo oscuro'),
    };

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () =>
          ref.read(themeModeNotifierProvider.notifier).cycleMode(),
    );
  }
}

// ----------------------------------------------------------------
// SyncButton — sincroniza gastos pendientes con Supabase
// ----------------------------------------------------------------
/// Botón reutilizable para disparar la sincronización manual.
/// Muestra el estado de la operación en un SnackBar.
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);

    // Mostrar resultado en SnackBar cuando cambia el estado
    ref.listen(syncNotifierProvider, (_, next) {
      if (next.isLoading) return;

      ScaffoldMessenger.of(context).clearSnackBars();

      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final result = next.value;
      if (result == null) return;

      // Construir mensaje con contadores de push y pull
      final String msg;
      final Color bgColor;

      if (result.nothingToDo) {
        msg = 'Todo al día ✓';
        bgColor = const Color(0xFF059669); // verde
      } else if (result.hasErrors) {
        final parts = <String>[
          if (result.synced > 0) '${result.synced} subidos',
          if (result.pulled > 0) '${result.pulled} descargados',
          if (result.deleted > 0) '${result.deleted} eliminados',
          '${result.failed} fallidos',
        ];
        msg = parts.join(' · ');
        bgColor = const Color(0xFFB45309); // ámbar oscuro
      } else {
        final parts = <String>[
          if (result.synced > 0) '${result.synced} subidos',
          if (result.pulled > 0) '${result.pulled} descargados',
          if (result.deleted > 0) '${result.deleted} eliminados',
        ];
        msg = '${parts.join(' · ')} ✓';
        bgColor = const Color(0xFF059669); // verde
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpiar estado tras mostrarlo
      ref.read(syncNotifierProvider.notifier).reset();
    });

    return IconButton(
      tooltip: 'Sincronizar con la nube',
      icon: syncState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_sync_outlined),
      onPressed: syncState.isLoading
          ? null
          : () => ref.read(syncNotifierProvider.notifier).syncNow(),
    );
  }
}

// ----------------------------------------------------------------
// SignOutButton — cierra la sesión del usuario
// ----------------------------------------------------------------
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text(
              '¿Deseas cerrar sesión? Los gastos no sincronizados '
              'seguirán guardados localmente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await ref.read(authNotifierProvider.notifier).signOut();
          // El router redirige automáticamente a /login vía authStateChanges
        }
      },
    );
  }
}
