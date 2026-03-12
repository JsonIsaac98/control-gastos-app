import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../domain/entities/gasto_entity.dart';
import '../../providers/gastos_provider.dart';
import '../widgets/gasto_card.dart';
import '../widgets/mes_selector.dart';
import 'main_shell_page.dart';

class GastosListPage extends ConsumerWidget {
  const GastosListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastosDelMesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: const [
          SyncButton(),
          ThemeToggleButton(),
          SignOutButton(),
          SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: MesSelector(),
          ),
        ),
      ),
      body: gastosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $e'),
              TextButton(
                onPressed: () => ref.refresh(gastosDelMesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (gastos) {
          if (gastos.isEmpty) {
            return const _EmptyHistorial();
          }

          final grupos = _agruparPorDia(gastos);

          return RefreshIndicator(
            onRefresh: () async =>
                ref.read(gastosDelMesProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: grupos.length,
              itemBuilder: (context, i) {
                final entrada = grupos[i];
                return _GrupoDia(
                  fecha: entrada.fecha,
                  gastos: entrada.gastos,
                  onDelete: (gasto) {
                    ref
                        .read(gastosDelMesProvider.notifier)
                        .deleteGasto(gasto.id!);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_GrupoDiaData> _agruparPorDia(List<GastoEntity> gastos) {
    final Map<String, _GrupoDiaData> grupos = {};

    for (final gasto in gastos) {
      final key = DateFormat('yyyy-MM-dd').format(gasto.fecha);
      if (!grupos.containsKey(key)) {
        grupos[key] = _GrupoDiaData(fecha: gasto.fecha, gastos: []);
      }
      grupos[key]!.gastos.add(gasto);
    }

    return grupos.values.toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}

class _GrupoDiaData {
  _GrupoDiaData({required this.fecha, required this.gastos});
  final DateTime fecha;
  final List<GastoEntity> gastos;
}

class _GrupoDia extends StatelessWidget {
  const _GrupoDia({
    required this.fecha,
    required this.gastos,
    required this.onDelete,
  });

  final DateTime fecha;
  final List<GastoEntity> gastos;
  final void Function(GastoEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final totalDia = gastos.fold(0.0, (sum, g) => sum + g.monto);
    final isToday = fecha.isSameDay(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday ? 'Hoy, ${fecha.dayMonth}' : fecha.formattedDateLong,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                totalDia.toCurrency,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        ...gastos.map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GastoCard(
              gasto: g,
              onDelete: () => onDelete(g),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _EmptyHistorial extends StatelessWidget {
  const _EmptyHistorial();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha:0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin gastos este mes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha:0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer gasto con el botón +',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha:0.5),
                ),
          ),
        ],
      ),
    );
  }
}
