import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/gasto_entity.dart';

class GastosLocalDatasource {
  GastosLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<GastoEntity>> getGastos() async {
    final rows = await (_db.select(_db.gastosTable)
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<List<GastoEntity>> getGastosByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final rows = await (_db.select(_db.gastosTable)
          ..where(
            (t) =>
                t.fecha.isBetweenValues(start, end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<double> getMonthlyTotal(int year, int month) async {
    final gastos = await getGastosByMonth(year, month);
    return gastos.fold<double>(0.0, (sum, g) => sum + g.monto);
  }

  Future<Map<TipoPago, double>> getMonthlyTotalByTipoPago(
      int year, int month) async {
    final gastos = await getGastosByMonth(year, month);
    final Map<TipoPago, double> totales = {};

    for (final gasto in gastos) {
      totales[gasto.tipoPago] =
          (totales[gasto.tipoPago] ?? 0.0) + gasto.monto;
    }
    return totales;
  }

  Future<GastoEntity> addGasto(GastoEntity gasto) async {
    final now = gasto.createdAt ?? DateTime.now();
    final id = await _db.into(_db.gastosTable).insert(
          GastosTableCompanion.insert(
            descripcion: gasto.descripcion,
            monto: gasto.monto,
            tipoPago: gasto.tipoPago.valor,
            fecha: gasto.fecha,
            createdAt: Value(now),
            // Siempre inicia como no sincronizado
            isSynced: const Value(false),
          ),
        );
    return gasto.copyWith(id: id, createdAt: now, isSynced: false);
  }

  Future<void> deleteGasto(int id) async {
    await (_db.delete(_db.gastosTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateGasto(GastoEntity gasto) async {
    await (_db.update(_db.gastosTable)
          ..where((t) => t.id.equals(gasto.id!)))
        .write(
      GastosTableCompanion(
        descripcion: Value(gasto.descripcion),
        monto: Value(gasto.monto),
        tipoPago: Value(gasto.tipoPago.valor),
        fecha: Value(gasto.fecha),
        // Al editar localmente, vuelve a quedar pendiente de sync
        isSynced: const Value(false),
        // Conserva el supabaseId para hacer upsert en el próximo sync
        supabaseId: Value(gasto.supabaseId),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Métodos de sincronización
  // ----------------------------------------------------------------

  /// Retorna todos los gastos que aún no han sido subidos a Supabase
  /// (is_synced == false), ordenados por fecha de creación ascendente.
  Future<List<GastoEntity>> getUnsyncedGastos() async {
    final rows = await (_db.select(_db.gastosTable)
          ..where((t) => t.isSynced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  /// Marca [localId] como sincronizado y guarda el [supabaseId] retornado.
  /// Se llama SOLO después de que Supabase confirma la escritura (20X).
  Future<void> markAsSynced(int localId, String supabaseId) async {
    await (_db.update(_db.gastosTable)
          ..where((t) => t.id.equals(localId)))
        .write(
      GastosTableCompanion(
        isSynced: const Value(true),
        supabaseId: Value(supabaseId),
      ),
    );
  }

  GastoEntity _toEntity(GastosTableData row) {
    return GastoEntity(
      id: row.id,
      descripcion: row.descripcion,
      monto: row.monto,
      tipoPago: TipoPago.fromValor(row.tipoPago),
      fecha: row.fecha,
      createdAt: row.createdAt,
      isSynced: row.isSynced,
      supabaseId: row.supabaseId,
    );
  }
}
