import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location     = GoRouterState.of(context).uri.toString();
    final currentIndex = location.startsWith('/historial') ? 1 : 0;

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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agregar'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Botón reutilizable para el toggle del tema.
/// Se agrega en el actions de cualquier AppBar.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeNotifierProvider);

    final (icon, tooltip) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto, 'Automático (sistema)'),
      ThemeMode.light  => (Icons.light_mode,       'Modo claro'),
      ThemeMode.dark   => (Icons.dark_mode,         'Modo oscuro'),
    };

    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () =>
          ref.read(themeModeNotifierProvider.notifier).cycleMode(),
    );
  }
}
