import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cuota_programada_entity.dart';
import '../../providers/cuotas_provider.dart';
import '../../../tarjetas/domain/entities/tarjeta_entity.dart';
import '../../../tarjetas/providers/tarjetas_provider.dart';
import '../pages/main_shell_page.dart';

class CuotasPage extends ConsumerWidget {
  const CuotasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todasAsync = ref.watch(todasLasCuotasProvider);
    final tarjetasAsync = ref.watch(tarjetasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuotas'),
        actions: const [ThemeToggleButton(), SyncButton()],
      ),
      body: todasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todas) {
          if (todas.isEmpty) return const _EmptyState();

          final tarjetas = tarjetasAsync.valueOrNull ?? [];

          // Agrupar por gastoOrigenId
          final Map<int, List<CuotaProgramadaEntity>> grupos = {};
          for (final c in todas) {
            grupos.putIfAbsent(c.gastoOrigenId, () => []).add(c);
          }
          // Ordenar grupos: los que tienen cuotas pendientes primero
          final grupos_ordenados = grupos.entries.toList()
            ..sort((a, b) {
              final aPendiente = a.value.any((c) => !c.isPagado);
              final bPendiente = b.value.any((c) => !c.isPagado);
              if (aPendiente && !bPendiente) return -1;
              if (!aPendiente && bPendiente) return 1;
              // Dentro de pendientes, ordenar por próxima fecha de vencimiento
              final aNext = a.value
                  .where((c) => !c.isPagado)
                  .map((c) => c.fechaVencimiento)
                  .fold<DateTime?>(null, (prev, d) =>
                      prev == null || d.isBefore(prev) ? d : prev);
              final bNext = b.value
                  .where((c) => !c.isPagado)
                  .map((c) => c.fechaVencimiento)
                  .fold<DateTime?>(null, (prev, d) =>
                      prev == null || d.isBefore(prev) ? d : prev);
              if (aNext != null && bNext != null) {
                return aNext.compareTo(bNext);
              }
              return 0;
            });

          // Resumen total pendiente
          final totalPendiente = todas
              .where((c) => !c.isPagado)
              .fold<double>(0, (s, c) => s + c.monto);
          final countPendientes = todas.where((c) => !c.isPagado).length;
          final countVencidas = todas
              .where((c) => c.isVencida)
              .length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todasLasCuotasProvider);
              ref.invalidate(cuotasPendientesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Resumen rápido
                _ResumenBanner(
                  pendientes: countPendientes,
                  vencidas: countVencidas,
                  totalPendiente: totalPendiente,
                ),
                const SizedBox(height: 16),

                // Grupos de cuotas
                ...grupos_ordenados.map(
                  (entry) => _GrupoCuotasCard(
                    cuotas: entry.value,
                    tarjetas: tarjetas,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------
// Banner de resumen
// ----------------------------------------------------------------
class _ResumenBanner extends StatelessWidget {
  const _ResumenBanner({
    required this.pendientes,
    required this.vencidas,
    required this.totalPendiente,
  });

  final int pendientes;
  final int vencidas;
  final double totalPendiente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _BannerItem(
                icon: Icons.pending_actions_outlined,
                valor: '$pendientes',
                label: 'Cuotas\npendientes',
                color: cs.primary,
              ),
            ),
            Container(
                height: 40, width: 1, color: cs.outlineVariant),
            Expanded(
              child: _BannerItem(
                icon: Icons.account_balance_wallet_outlined,
                valor: 'Q ${totalPendiente.toStringAsFixed(2)}',
                label: 'Total\npendiente',
                color: cs.secondary,
              ),
            ),
            if (vencidas > 0) ...[
              Container(
                  height: 40, width: 1, color: cs.outlineVariant),
              Expanded(
                child: _BannerItem(
                  icon: Icons.warning_amber_rounded,
                  valor: '$vencidas',
                  label: 'Cuotas\nvencidas',
                  color: cs.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.icon,
    required this.valor,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String valor;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          valor,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------
// Tarjeta agrupada con ExpansionTile
// ----------------------------------------------------------------
class _GrupoCuotasCard extends ConsumerWidget {
  const _GrupoCuotasCard({
    required this.cuotas,
    required this.tarjetas,
  });

  final List<CuotaProgramadaEntity> cuotas;
  final List<TarjetaEntity> tarjetas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ordenar cuotas por número de cuota
    final ordenadas = [...cuotas]
      ..sort((a, b) => a.numeroCuota.compareTo(b.numeroCuota));

    final pagadas = ordenadas.where((c) => c.isPagado).length;
    final pendientes = ordenadas.where((c) => !c.isPagado).toList();
    final vencidas = pendientes.where((c) => c.isVencida).length;
    final total = ordenadas.first.totalCuotas;
    final montoTotal = ordenadas.first.monto * total;
    final descripcion = ordenadas.first.descripcion;

    // Tarjeta asociada
    final tarjeta = cuotas.first.tarjetaId != null
        ? tarjetas
            .where((t) => t.id == cuotas.first.tarjetaId)
            .firstOrNull
        : null;

    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final bool todosPagado = pendientes.isEmpty;
    final Color accentColor = todosPagado
        ? const Color(0xFF059669)
        : vencidas > 0
            ? cs.error
            : cs.primary;

    // Color de la tarjeta
    final Color? tarjetaColor = tarjeta?.color != null
        ? Color(int.parse(
            tarjeta!.color!.replaceFirst('#', '0xFF')))
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context)
              .copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: !todosPagado,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: EdgeInsets.zero,
            // Header
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (tarjetaColor ?? accentColor).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.credit_card,
                color: tarjetaColor ?? accentColor,
                size: 22,
              ),
            ),
            title: Text(
              descripcion,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Progreso
                    Text(
                      '$pagadas/$total cuotas pagadas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (vencidas > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$vencidas vencida${vencidas > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: cs.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Nombre de tarjeta
                    if (tarjeta != null) ...[
                      Icon(Icons.credit_card,
                          size: 11,
                          color: tarjetaColor ??
                              cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        tarjeta.nombre,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tarjetaColor ?? cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      'Total: Q ${montoTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Barra de progreso
            trailing: _ProgressIndicator(
              pagadas: pagadas,
              total: total,
              color: accentColor,
            ),
            children: [
              // Barra de progreso visual
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pagadas / total,
                    backgroundColor:
                        accentColor.withValues(alpha: 0.15),
                    color: accentColor,
                    minHeight: 4,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Lista de cuotas individuales
              ...ordenadas.map(
                (c) => _FilaCuota(cuota: c),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.pagadas,
    required this.total,
    required this.color,
  });

  final int pagadas;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pagadas/$total',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Icon(Icons.expand_more,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ],
    );
  }
}

// ----------------------------------------------------------------
// Fila individual de cuota dentro del ExpansionTile
// ----------------------------------------------------------------
class _FilaCuota extends ConsumerWidget {
  const _FilaCuota({required this.cuota});

  final CuotaProgramadaEntity cuota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color statusColor;
    final IconData statusIcon;
    if (cuota.isPagado) {
      statusColor = const Color(0xFF059669);
      statusIcon = Icons.check_circle_outline;
    } else if (cuota.isVencida) {
      statusColor = cs.error;
      statusIcon = Icons.warning_amber_rounded;
    } else if (cuota.isProxima) {
      statusColor = cs.tertiary;
      statusIcon = Icons.upcoming_outlined;
    } else {
      statusColor = cs.onSurfaceVariant;
      statusIcon = Icons.schedule_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Número de cuota
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${cuota.numeroCuota}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Fecha de vencimiento o pago
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cuota.isPagado
                      ? 'Pagado el ${_fmt(cuota.fechaPagado!)}'
                      : 'Vence el ${_fmt(cuota.fechaVencimiento)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!cuota.isPagado && cuota.isVencida)
                  Text(
                    'Atrasada',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.error,
                    ),
                  ),
              ],
            ),
          ),
          // Monto
          Text(
            'Q ${cuota.monto.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 8),
          // Estado o botón registrar
          if (cuota.isPagado)
            Icon(statusIcon, size: 18, color: statusColor)
          else
            TextButton(
              onPressed: () => _confirmarPago(context, ref),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Pagar', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<void> _confirmarPago(
      BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar pago'),
        content: Text(
          'Cuota ${cuota.numeroCuota}/${cuota.totalCuotas} de '
          '"${cuota.descripcion}"\n\n'
          'Se creará un gasto de Q ${cuota.monto.toStringAsFixed(2)} con la fecha de hoy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ref
          .read(cuotasPendientesProvider.notifier)
          .registrarPago(cuota);
      ref.invalidate(todasLasCuotasProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cuota ${cuota.numeroCuota}/${cuota.totalCuotas} pagada ✓',
            ),
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

// ----------------------------------------------------------------
// Estado vacío
// ----------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_off_outlined,
                size: 72,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Sin cuotas registradas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando registres un gasto con tarjeta de crédito a cuotas, '
              'aparecerá el seguimiento aquí.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
