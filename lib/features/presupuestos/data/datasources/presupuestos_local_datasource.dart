import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/presupuesto_entity.dart';

class PresupuestosLocalDatasource {
  PresupuestosLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<PresupuestoEntity>> getPresupuestosByMes(DateTime mes) async {
    final firstDay = DateTime(mes.year, mes.month, 1);
    final rows = await (_db.select(_db.presupuestosTable)
          ..where((t) => t.mes.equals(firstDay)))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> upsertPresupuesto(PresupuestoEntity p) async {
    await _db.into(_db.presupuestosTable).insertOnConflictUpdate(
          PresupuestosTableCompanion(
            id: Value(p.id),
            userId: Value(p.userId),
            categoriaId: Value(p.categoriaId),
            montoLimite: Value(p.montoLimite),
            mes: Value(p.mes),
            isSynced: Value(p.isSynced),
          ),
        );
  }

  Future<List<PresupuestoEntity>> getUnsyncedPresupuestos() async {
    final rows = await (_db.select(_db.presupuestosTable)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_db.update(_db.presupuestosTable)
          ..where((t) => t.id.equals(id)))
        .write(const PresupuestosTableCompanion(isSynced: Value(true)));
  }

  Future<void> deletePresupuesto(String id) async {
    await (_db.delete(_db.presupuestosTable)..where((t) => t.id.equals(id)))
        .go();
  }

  PresupuestoEntity _toEntity(PresupuestosTableData row) => PresupuestoEntity(
        id: row.id,
        userId: row.userId,
        categoriaId: row.categoriaId,
        montoLimite: row.montoLimite,
        mes: row.mes,
        isSynced: row.isSynced,
      );
}
