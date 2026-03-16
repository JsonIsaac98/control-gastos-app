import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/extensions/date_extensions.dart';
import '../../../categorias/domain/entities/categoria_entity.dart';
import '../../../categorias/providers/categorias_provider.dart';
import '../../../presupuestos/providers/presupuestos_provider.dart';
import '../../domain/entities/gasto_entity.dart';
import '../../providers/gastos_provider.dart';
import '../widgets/gasto_card.dart';
import '../widgets/mes_selector.dart';
import 'main_shell_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(dashboardResumenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Personal'),
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
      body: resumenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $e'),
              TextButton(
                onPressed: () => ref.refresh(dashboardResumenProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (resumen) => RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardResumenProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _TotalCard(total: resumen.totalMes, cantidad: resumen.cantidadGastos),
              const SizedBox(height: 16),
              _DesgloseTipoPago(totales: resumen.totalPorTipo),
              const SizedBox(height: 16),
              if (resumen.totalPorCategoria.isNotEmpty)
                _DesgloseCategorias(
                  totalPorCategoria: resumen.totalPorCategoria,
                  totalGeneral: resumen.totalMes,
                  mes: ref.watch(selectedMonthProvider),
                ),
              if (resumen.totalPorCategoria.isNotEmpty) const SizedBox(height: 16),
              if (resumen.ultimos.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos gastos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${resumen.cantidadGastos} en total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...resumen.ultimos.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GastoCard(
                      gasto: g,
                      onDelete: () {
                        ref
                            .read(gastosDelMesProvider.notifier)
                            .deleteGasto(g.id!);
                      },
                    ),
                  ),
                ),
              ] else
                _EmptyState(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.cantidad});

  final double total;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total del mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              total.toCurrency,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$cantidad ${cantidad == 1 ? 'gasto registrado' : 'gastos registrados'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesgloseTipoPago extends StatelessWidget {
  const _DesgloseTipoPago({required this.totales});

  final Map<TipoPago, double> totales;

  @override
  Widget build(BuildContext context) {
    if (totales.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por tipo de pago',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...TipoPago.values
                .where((t) => totales.containsKey(t))
                .map(
                  (tipo) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TipoPagoRow(
                      tipo: tipo,
                      monto: totales[tipo] ?? 0,
                      totalGeneral: totales.values.fold(0, (a, b) => a + b),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _TipoPagoRow extends StatelessWidget {
  const _TipoPagoRow({
    required this.tipo,
    required this.monto,
    required this.totalGeneral,
  });

  final TipoPago tipo;
  final double monto;
  final double totalGeneral;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final porcentaje = totalGeneral > 0 ? monto / totalGeneral : 0.0;
    final (color, bgColor, icon) = _getStyle(tipo, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tipo.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              monto.toCurrency,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  (Color, Color, IconData) _getStyle(TipoPago tipo, bool isDark) {
    return switch (tipo) {
      TipoPago.efectivo => (
          isDark ? AppColors.efectivoDark : AppColors.efectivo,
          isDark ? AppColors.efectivoBgDark : AppColors.efectivoBg,
          Icons.money,
        ),
      TipoPago.tarjetaCredito => (
          isDark ? AppColors.tarjetaDark : AppColors.tarjeta,
          isDark ? AppColors.tarjetaBgDark : AppColors.tarjetaBg,
          Icons.credit_card,
        ),
      TipoPago.transferencia => (
          isDark ? AppColors.transferDark : AppColors.transfer,
          isDark ? AppColors.transferBgDark : AppColors.transferBg,
          Icons.swap_horiz,
        ),
    };
  }
}

// ----------------------------------------------------------------
// Desglose por categoría
// ----------------------------------------------------------------
class _DesgloseCategorias extends ConsumerWidget {
  const _DesgloseCategorias({
    required this.totalPorCategoria,
    required this.totalGeneral,
    required this.mes,
  });

  final Map<String, double> totalPorCategoria;
  final double totalGeneral;
  final DateTime mes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final presupuestosAsync = ref.watch(presupuestosMesProvider(mes));

    return categoriasAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categorias) {
        // Solo mostrar categorías que tienen gastos en este mes
        final catsConGastos = categorias
            .where((c) => totalPorCategoria.containsKey(c.id))
            .toList();

        if (catsConGastos.isEmpty) return const SizedBox.shrink();

        // Mapa de categoriaId → presupuesto para acceso rápido
        final Map<String, double> limites = {};
        presupuestosAsync.whenData((presupuestos) {
          for (final p in presupuestos) {
            if (p.categoriaId != null) {
              limites[p.categoriaId!] = p.montoLimite;
            }
          }
        });

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Por categoría',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...catsConGastos.map((cat) {
                  final monto = totalPorCategoria[cat.id] ?? 0.0;
                  final limite = limites[cat.id];
                  final pct =
                      totalGeneral > 0 ? monto / totalGeneral : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoriaRow(
                      categoria: cat,
                      monto: monto,
                      porcentaje: pct,
                      limite: limite,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoriaRow extends StatelessWidget {
  const _CategoriaRow({
    required this.categoria,
    required this.monto,
    required this.porcentaje,
    this.limite,
  });

  final CategoriaEntity categoria;
  final double monto;
  final double porcentaje;
  final double? limite;

  @override
  Widget build(BuildContext context) {
    final color =
        categoria.colorValue ?? Theme.of(context).colorScheme.primary;
    final bgColor = color.withValues(alpha: 0.12);
    final pctText = '${(porcentaje * 100).toStringAsFixed(0)}%';

    // Progreso del presupuesto si existe
    double? budgetProgress;
    if (limite != null && limite! > 0) {
      budgetProgress = (monto / limite!).clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icono de categoría
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                categoria.icono ?? '📦',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoria.nombre,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  monto.toCurrency,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  pctText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Barra de progreso vs total
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        // Barra de presupuesto si existe
        if (budgetProgress != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budgetProgress,
                    backgroundColor: bgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetProgress >= 0.9
                          ? Colors.red
                          : budgetProgress >= 0.7
                              ? Colors.orange
                              : color,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(budgetProgress * 100).toStringAsFixed(0)}% del pres. (${limite!.toCurrency})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin gastos este mes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca "Nuevo Gasto" para empezar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
