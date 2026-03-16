import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/categoria_entity.dart';

class CategoriasLocalDatasource {
  CategoriasLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<CategoriaEntity>> getCategorias() async {
    final rows = await (_db.select(_db.categoriasTable)
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<CategoriaEntity?> getCategoriaById(String id) async {
    final row = await (_db.select(_db.categoriasTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  Future<void> upsertCategoria(CategoriaEntity c) async {
    await _db.into(_db.categoriasTable).insertOnConflictUpdate(
          CategoriasTableCompanion.insert(
            id: c.id,
            userId: Value(c.userId),
            nombre: c.nombre,
            icono: Value(c.icono),
            color: Value(c.color),
            esDefault: Value(c.esDefault),
          ),
        );
  }

  Future<void> deleteCategoria(String id) async {
    await (_db.delete(_db.categoriasTable)..where((t) => t.id.equals(id)))
        .go();
  }

  CategoriaEntity _toEntity(CategoriasTableData row) => CategoriaEntity(
        id: row.id,
        userId: row.userId,
        nombre: row.nombre,
        icono: row.icono,
        color: row.color,
        esDefault: row.esDefault,
      );
}
