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
    final id = await _db.into(_db.gastosTable).insert(
          GastosTableCompanion.insert(
            descripcion: gasto.descripcion,
            monto: gasto.monto,
            tipoPago: gasto.tipoPago.valor,
            fecha: gasto.fecha,
            createdAt: Value(gasto.createdAt ?? DateTime.now()),
          ),
        );
    return gasto.copyWith(id: id, createdAt: gasto.createdAt ?? DateTime.now());
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
    );
  }
}
