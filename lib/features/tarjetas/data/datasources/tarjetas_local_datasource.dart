import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/tarjeta_entity.dart';

class TarjetasLocalDatasource {
  TarjetasLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<TarjetaEntity>> getTarjetas() async {
    final rows = await (_db.select(_db.tarjetasCreditoTable)
          ..orderBy([(t) => OrderingTerm.asc(t.orden),
                     (t) => OrderingTerm.asc(t.nombre)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<TarjetaEntity?> getTarjetaById(String id) async {
    final row = await (_db.select(_db.tarjetasCreditoTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  Future<void> addTarjeta(TarjetaEntity tarjeta) async {
    await _db.into(_db.tarjetasCreditoTable).insertOnConflictUpdate(
          TarjetasCreditoTableCompanion.insert(
            id: tarjeta.id,
            nombre: tarjeta.nombre,
            diaCorte: tarjeta.diaCorte,
            color: Value(tarjeta.color),
            isDefault: Value(tarjeta.isDefault),
            orden: Value(tarjeta.orden),
          ),
        );
  }

  Future<void> updateTarjeta(TarjetaEntity tarjeta) async {
    await (_db.update(_db.tarjetasCreditoTable)
          ..where((t) => t.id.equals(tarjeta.id)))
        .write(
      TarjetasCreditoTableCompanion(
        nombre: Value(tarjeta.nombre),
        diaCorte: Value(tarjeta.diaCorte),
        color: Value(tarjeta.color),
        isDefault: Value(tarjeta.isDefault),
        orden: Value(tarjeta.orden),
      ),
    );
  }

  Future<void> deleteTarjeta(String id) async {
    await (_db.delete(_db.tarjetasCreditoTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  TarjetaEntity _toEntity(TarjetasCreditoTableData row) {
    return TarjetaEntity(
      id: row.id,
      nombre: row.nombre,
      diaCorte: row.diaCorte,
      color: row.color,
      isDefault: row.isDefault,
      orden: row.orden,
    );
  }
}
