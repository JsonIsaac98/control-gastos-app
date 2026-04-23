import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../data/datasources/cuotas_local_datasource.dart';
import '../domain/entities/cuota_programada_entity.dart';
import '../domain/entities/gasto_entity.dart';
import 'gastos_provider.dart';
import 'gastos_repository_provider.dart';

part 'cuotas_provider.g.dart';

// ----------------------------------------------------------------
// Datasource de cuotas
// ----------------------------------------------------------------
@Riverpod(keepAlive: true)
CuotasLocalDatasource cuotasLocalDatasource(CuotasLocalDatasourceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return CuotasLocalDatasource(db);
}

// ----------------------------------------------------------------
// Lista de cuotas pendientes (para el tab Cuotas)
// ----------------------------------------------------------------
@riverpod
class CuotasPendientes extends _$CuotasPendientes {
  @override
  Future<List<CuotaProgramadaEntity>> build() async {
    return ref
        .watch(cuotasLocalDatasourceProvider)
        .getCuotasPendientes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(cuotasLocalDatasourceProvider).getCuotasPendientes(),
    );
  }

  // ----------------------------------------------------------------
  // Registrar el pago de una cuota pendiente
  // ----------------------------------------------------------------
  /// Crea un nuevo [GastoEntity] con el monto de la cuota y lo vincula.
  Future<void> registrarPago(CuotaProgramadaEntity cuota) async {
    final repository = ref.read(gastosRepositoryProvider);
    final datasource = ref.read(cuotasLocalDatasourceProvider);
    final ahora = DateTime.now();

    // Crear un gasto real para esta cuota
    final gasto = GastoEntity(
      descripcion: 'Cuota ${cuota.numeroCuota}/${cuota.totalCuotas} · ${cuota.descripcion}',
      monto: cuota.monto,
      tipoPago: TipoPago.tarjetaCredito,
      fecha: ahora,
    );
    final gastoGuardado = await repository.addGasto(gasto);

    // Marcar la cuota como pagada
    await datasource.registrarPago(
      cuotaId: cuota.id!,
      gastoRegistradoId: gastoGuardado.id!,
      fechaPagado: ahora,
    );

    await refresh();
    ref.invalidate(dashboardResumenProvider);
    ref.invalidate(gastosDelMesProvider);
  }
}

// ----------------------------------------------------------------
// Todas las cuotas (pendientes + pagadas) para el historial
// ----------------------------------------------------------------
@riverpod
Future<List<CuotaProgramadaEntity>> todasLasCuotas(
    TodasLasCuotasRef ref) async {
  return ref.watch(cuotasLocalDatasourceProvider).getTodasLasCuotas();
}
