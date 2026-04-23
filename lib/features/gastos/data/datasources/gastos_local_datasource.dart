import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/gasto_entity.dart';

class GastosLocalDatasource {
  GastosLocalDatasource(this._db);

  final AppDatabase _db;

  // ----------------------------------------------------------------
  // Lectura — siempre excluye registros marcados como pendingDelete
  // ----------------------------------------------------------------

  Future<List<GastoEntity>> getGastos() async {
    final rows = await (_db.select(_db.gastosTable)
          ..where((t) => t.pendingDelete.equals(false))
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
                t.pendingDelete.equals(false) &
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

  // ----------------------------------------------------------------
  // Escritura
  // ----------------------------------------------------------------

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
            categoriaId: Value(gasto.categoriaId),
            fotoUrl: Value(gasto.fotoUrl),
            esCuota: Value(gasto.esCuota),
            numeroCuotas: Value(gasto.numeroCuotas),
            frecuenciaCuotas: Value(gasto.frecuenciaCuotas),
            tarjetaId: Value(gasto.tarjetaId),
          ),
        );
    return gasto.copyWith(id: id, createdAt: now, isSynced: false);
  }

  /// Elimina un gasto de forma inteligente según su estado de sincronización:
  ///
  /// - Si el registro nunca llegó a Supabase ([supabaseId] == null):
  ///   eliminación física inmediata (nunca existió en la nube).
  /// - Si ya fue sincronizado ([supabaseId] != null):
  ///   **soft delete** → marca [pendingDelete] = true y lo oculta de la UI.
  ///   El registro físico se elimina de Supabase y luego de SQLite durante
  ///   el próximo sync (fase 0 de [SyncService.fullSync]).
  Future<void> deleteGasto(int id) async {
    // Buscar el registro para saber si tiene supabaseId
    final row = await (_db.select(_db.gastosTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return;

    // Eliminar cuotas relacionadas (Supabase tiene ON DELETE CASCADE,
    // así que no es necesario eliminarlas allá manualmente).
    await (_db.delete(_db.cuotasProgramadasTable)
          ..where((t) => t.gastoOrigenId.equals(id)))
        .go();

    if (row.supabaseId == null) {
      // Nunca estuvo en Supabase → borrado físico inmediato
      await (_db.delete(_db.gastosTable)..where((t) => t.id.equals(id))).go();
    } else {
      // Ya está en Supabase → soft delete para procesarlo en el sync
      await (_db.update(_db.gastosTable)..where((t) => t.id.equals(id)))
          .write(const GastosTableCompanion(
        pendingDelete: Value(true),
      ));
    }
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
        categoriaId: Value(gasto.categoriaId),
        fotoUrl: Value(gasto.fotoUrl),
        esCuota: Value(gasto.esCuota),
        numeroCuotas: Value(gasto.numeroCuotas),
        frecuenciaCuotas: Value(gasto.frecuenciaCuotas),
        tarjetaId: Value(gasto.tarjetaId),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Métodos de sincronización — Push
  // ----------------------------------------------------------------

  Future<GastoEntity?> getGastoById(int id) async {
    final row = await (_db.select(_db.gastosTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  /// Retorna todos los gastos que aún no han sido subidos a Supabase
  /// (is_synced == false) y que NO están pendientes de eliminar,
  /// ordenados por fecha de creación ascendente.
  Future<List<GastoEntity>> getUnsyncedGastos() async {
    final rows = await (_db.select(_db.gastosTable)
          ..where(
            (t) =>
                t.isSynced.equals(false) & t.pendingDelete.equals(false),
          )
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

  // ----------------------------------------------------------------
  // Métodos de sincronización — Eliminación (fase 0)
  // ----------------------------------------------------------------

  /// Retorna todos los registros marcados con [pendingDelete] = true.
  /// La fase 0 del sync los elimina de Supabase y luego físicamente.
  Future<List<GastosTableData>> getPendingDeletes() async {
    return (_db.select(_db.gastosTable)
          ..where((t) => t.pendingDelete.equals(true)))
        .get();
  }

  /// Elimina físicamente de SQLite el registro con [id] y sus cuotas.
  /// Llamar SOLO después de confirmar la eliminación en Supabase.
  Future<void> hardDeleteById(int id) async {
    await (_db.delete(_db.cuotasProgramadasTable)
          ..where((t) => t.gastoOrigenId.equals(id)))
        .go();
    await (_db.delete(_db.gastosTable)..where((t) => t.id.equals(id))).go();
  }

  // ----------------------------------------------------------------
  // Métodos de sincronización — Pull
  // ----------------------------------------------------------------

  /// Retorna true si ya existe un registro local con el [supabaseId] dado,
  /// incluyendo los marcados como [pendingDelete] (para no re-insertarlos
  /// antes de que el sync los elimine de Supabase).
  Future<bool> existsBySupabaseId(String supabaseId) async {
    final row = await (_db.select(_db.gastosTable)
          ..where((t) => t.supabaseId.equals(supabaseId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Inserta un gasto proveniente de Supabase en la base de datos local.
  ///
  /// El gasto se marca como [isSynced] = true inmediatamente, ya que
  /// su origen es la nube y no necesita volver a subirse.
  Future<void> insertFromRemote(Map<String, dynamic> data) async {
    await _db.into(_db.gastosTable).insert(
          GastosTableCompanion.insert(
            descripcion: data['descripcion'] as String,
            monto: (data['monto'] as num).toDouble(),
            tipoPago: data['tipo_pago'] as String,
            fecha: DateTime.parse(data['fecha'] as String).toLocal(),
            createdAt: Value(
              DateTime.parse(data['created_at'] as String).toLocal(),
            ),
            isSynced: const Value(true),
            supabaseId: Value(data['id'] as String),
            categoriaId: Value(data['categoria_id'] as String?),
            fotoUrl: Value(data['foto_url'] as String?),
            esCuota: Value((data['es_cuota'] as bool?) ?? false),
            numeroCuotas: Value(data['numero_cuotas'] as int?),
            frecuenciaCuotas: Value(data['frecuencia_cuotas'] as String?),
            tarjetaId: Value(data['tarjeta_id'] as String?),
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
      categoriaId: row.categoriaId,
      fotoUrl: row.fotoUrl,
      esCuota: row.esCuota,
      numeroCuotas: row.numeroCuotas,
      frecuenciaCuotas: row.frecuenciaCuotas,
      tarjetaId: row.tarjetaId,
    );
  }
}
