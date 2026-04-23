import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/cuota_programada_entity.dart';
import '../../domain/entities/gasto_entity.dart';

class CuotasLocalDatasource {
  CuotasLocalDatasource(this._db);

  final AppDatabase _db;

  // ----------------------------------------------------------------
  // Lectura
  // ----------------------------------------------------------------

  Future<List<CuotaProgramadaEntity>> getCuotasPendientes() async {
    final rows = await (_db.select(_db.cuotasProgramadasTable)
          ..where((t) => t.isPagado.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.fechaVencimiento)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<List<CuotaProgramadaEntity>> getCuotasForGasto(
      int gastoOrigenId) async {
    final rows = await (_db.select(_db.cuotasProgramadasTable)
          ..where((t) => t.gastoOrigenId.equals(gastoOrigenId))
          ..orderBy([(t) => OrderingTerm.asc(t.numeroCuota)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<List<CuotaProgramadaEntity>> getTodasLasCuotas() async {
    final rows = await (_db.select(_db.cuotasProgramadasTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.isPagado),
            (t) => OrderingTerm.asc(t.fechaVencimiento),
          ]))
        .get();
    return rows.map(_toEntity).toList();
  }

  // ----------------------------------------------------------------
  // Creación automática al registrar una compra a cuotas
  // ----------------------------------------------------------------

  /// Crea [gasto.numeroCuotas] registros programados.
  ///
  /// - La cuota 1 se marca como pagada y vinculada al gasto origen.
  /// - Las cuotas 2..N quedan pendientes con la fecha de corte calculada.
  Future<void> crearCuotasProgramadas({
    required GastoEntity gastoOrigen,
    required int diaCorte,
  }) async {
    final n = gastoOrigen.numeroCuotas!;
    final monto = gastoOrigen.monto; // ya es el monto por cuota

    final primer = _primerVencimiento(gastoOrigen.fecha, diaCorte);

    for (int i = 0; i < n; i++) {
      final fechaVenc = _addMonths(primer, i);
      final esPrimera = i == 0;

      await _db.into(_db.cuotasProgramadasTable).insert(
            CuotasProgramadasTableCompanion.insert(
              gastoOrigenId: gastoOrigen.id!,
              gastoOrigenSupabaseId: Value(gastoOrigen.supabaseId),
              descripcion: gastoOrigen.descripcion,
              numeroCuota: i + 1,
              totalCuotas: n,
              monto: monto,
              fechaVencimiento: fechaVenc,
              isPagado: Value(esPrimera),
              fechaPagado: Value(esPrimera ? gastoOrigen.fecha : null),
              gastoRegistradoId:
                  Value(esPrimera ? gastoOrigen.id : null),
              tarjetaId: Value(gastoOrigen.tarjetaId),
            ),
          );
    }
  }

  // ----------------------------------------------------------------
  // Registrar pago de una cuota pendiente
  // ----------------------------------------------------------------

  /// Marca la cuota [cuotaId] como pagada y la vincula al gasto registrado.
  Future<void> registrarPago({
    required int cuotaId,
    required int gastoRegistradoId,
    required DateTime fechaPagado,
  }) async {
    await (_db.update(_db.cuotasProgramadasTable)
          ..where((t) => t.id.equals(cuotaId)))
        .write(
      CuotasProgramadasTableCompanion(
        isPagado: const Value(true),
        fechaPagado: Value(fechaPagado),
        gastoRegistradoId: Value(gastoRegistradoId),
        isSynced: const Value(false),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Helpers de fecha
  // ----------------------------------------------------------------

  /// Calcula el primer vencimiento basado en el día de corte.
  /// Siempre usa el día de corte del mismo mes/año de la compra.
  DateTime _primerVencimiento(DateTime fechaCompra, int diaCorte) {
    final ultimo = DateTime(fechaCompra.year, fechaCompra.month + 1, 0).day;
    return DateTime(
        fechaCompra.year, fechaCompra.month, diaCorte.clamp(1, ultimo));
  }

  /// Suma [meses] meses a [fecha] ajustando por días del mes.
  DateTime _addMonths(DateTime fecha, int meses) {
    int mes = fecha.month + meses;
    int anio = fecha.year;
    while (mes > 12) {
      mes -= 12;
      anio++;
    }
    final ultimo = DateTime(anio, mes + 1, 0).day;
    return DateTime(anio, mes, fecha.day.clamp(1, ultimo));
  }

  // ----------------------------------------------------------------
  // Sync helpers
  // ----------------------------------------------------------------

  Future<List<CuotaProgramadaEntity>> getUnsyncedCuotas() async {
    final rows = await (_db.select(_db.cuotasProgramadasTable)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> markCuotaAsSynced(int id, String supabaseId) async {
    await (_db.update(_db.cuotasProgramadasTable)
          ..where((t) => t.id.equals(id)))
        .write(CuotasProgramadasTableCompanion(
      isSynced: const Value(true),
      supabaseId: Value(supabaseId),
    ));
  }

  /// Actualiza gastoOrigenSupabaseId de todas las cuotas de un gasto local.
  Future<void> updateGastoOrigenSupabaseId(
      int gastoOrigenId, String supabaseId) async {
    await (_db.update(_db.cuotasProgramadasTable)
          ..where((t) => t.gastoOrigenId.equals(gastoOrigenId)))
        .write(CuotasProgramadasTableCompanion(
      gastoOrigenSupabaseId: Value(supabaseId),
      isSynced: const Value(false),
    ));
  }

  Future<bool> existsBySupabaseId(String supabaseId) async {
    final row = await (_db.select(_db.cuotasProgramadasTable)
          ..where((t) => t.supabaseId.equals(supabaseId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> upsertFromRemote(Map<String, dynamic> remote) async {
    final supabaseId = remote['id'] as String;
    final exists = await existsBySupabaseId(supabaseId);
    if (exists) return;

    await _db.into(_db.cuotasProgramadasTable).insert(
          CuotasProgramadasTableCompanion.insert(
            gastoOrigenId: 0,
            gastoOrigenSupabaseId: Value(remote['gasto_origen_id'] as String?),
            descripcion: remote['descripcion'] as String,
            numeroCuota: remote['numero_cuota'] as int,
            totalCuotas: remote['total_cuotas'] as int,
            monto: (remote['monto'] as num).toDouble(),
            fechaVencimiento:
                DateTime.parse(remote['fecha_vencimiento'] as String),
            isPagado: Value(remote['is_pagado'] as bool? ?? false),
            fechaPagado: Value(remote['fecha_pagado'] != null
                ? DateTime.parse(remote['fecha_pagado'] as String)
                : null),
            tarjetaId: Value(remote['tarjeta_id'] as String?),
            isSynced: const Value(true),
            supabaseId: Value(supabaseId),
          ),
        );
  }

  // ----------------------------------------------------------------
  // Mapeo
  // ----------------------------------------------------------------

  CuotaProgramadaEntity _toEntity(CuotasProgramadasTableData row) {
    return CuotaProgramadaEntity(
      id: row.id,
      gastoOrigenId: row.gastoOrigenId,
      gastoOrigenSupabaseId: row.gastoOrigenSupabaseId,
      descripcion: row.descripcion,
      numeroCuota: row.numeroCuota,
      totalCuotas: row.totalCuotas,
      monto: row.monto,
      fechaVencimiento: row.fechaVencimiento,
      isPagado: row.isPagado,
      fechaPagado: row.fechaPagado,
      gastoRegistradoId: row.gastoRegistradoId,
      isSynced: row.isSynced,
      supabaseId: row.supabaseId,
      tarjetaId: row.tarjetaId,
    );
  }
}
