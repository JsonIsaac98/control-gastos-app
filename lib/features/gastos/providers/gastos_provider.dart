import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/gasto_entity.dart';
import 'gastos_repository_provider.dart';

part 'gastos_provider.g.dart';

/// Estado del mes seleccionado para filtrar gastos
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    final next = DateTime(state.year, state.month + 1, 1);
    if (next.isBefore(DateTime.now()) ||
        (next.year == DateTime.now().year && next.month == DateTime.now().month)) {
      state = next;
    }
  }
}

/// Lista de gastos del mes seleccionado
@riverpod
class GastosDelMes extends _$GastosDelMes {
  @override
  Future<List<GastoEntity>> build() async {
    final month = ref.watch(selectedMonthProvider);
    final repository = ref.watch(gastosRepositoryProvider);
    return repository.getGastosByMonth(month.year, month.month);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final month = ref.read(selectedMonthProvider);
      final repository = ref.read(gastosRepositoryProvider);
      return repository.getGastosByMonth(month.year, month.month);
    });
  }

  Future<void> addGasto(GastoEntity gasto) async {
    final repository = ref.read(gastosRepositoryProvider);
    await repository.addGasto(gasto);
    await refresh();
    // Invalidar también el dashboard
    ref.invalidate(dashboardResumenProvider);
  }

  Future<void> deleteGasto(int id) async {
    final repository = ref.read(gastosRepositoryProvider);
    await repository.deleteGasto(id);
    await refresh();
    ref.invalidate(dashboardResumenProvider);
  }
}

/// Lista de gastos de un mes específico (para uso en reportes y presupuestos).
/// Acepta un DateTime como parámetro para consultar cualquier mes.
@riverpod
Future<List<GastoEntity>> gastosDelMesPorFecha(
    GastosDelMesPorFechaRef ref, DateTime mes) async {
  final repository = ref.watch(gastosRepositoryProvider);
  return repository.getGastosByMonth(mes.year, mes.month);
}

/// Resumen del dashboard para el mes seleccionado
@riverpod
Future<DashboardResumen> dashboardResumen(DashboardResumenRef ref) async {
  final month = ref.watch(selectedMonthProvider);
  final repository = ref.watch(gastosRepositoryProvider);

  final total = await repository.getMonthlyTotal(month.year, month.month);
  final porTipo =
      await repository.getMonthlyTotalByTipoPago(month.year, month.month);
  final gastos =
      await repository.getGastosByMonth(month.year, month.month);

  // Calcular total por categoría
  final Map<String, double> porCategoria = {};
  for (final g in gastos) {
    if (g.categoriaId != null) {
      porCategoria[g.categoriaId!] =
          (porCategoria[g.categoriaId!] ?? 0.0) + g.monto;
    }
  }

  return DashboardResumen(
    totalMes: total,
    totalPorTipo: porTipo,
    ultimos: gastos.take(5).toList(),
    cantidadGastos: gastos.length,
    totalPorCategoria: porCategoria,
  );
}

class DashboardResumen {
  const DashboardResumen({
    required this.totalMes,
    required this.totalPorTipo,
    required this.ultimos,
    required this.cantidadGastos,
    this.totalPorCategoria = const {},
  });

  final double totalMes;
  final Map<TipoPago, double> totalPorTipo;
  final List<GastoEntity> ultimos;
  final int cantidadGastos;
  /// Mapa de categoriaId → total gastado en el mes
  final Map<String, double> totalPorCategoria;
}
