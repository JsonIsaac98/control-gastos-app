import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ----------------------------------------------------------------
// Tabla de gastos
// ----------------------------------------------------------------
class GastosTable extends Table {
  @override
  String get tableName => 'gastos';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get descripcion => text().withLength(min: 1, max: 200)();
  RealColumn get monto => real()();
  // efectivo | tarjeta_credito | transferencia
  TextColumn get tipoPago => text()();
  DateTimeColumn get fecha => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ── Columnas de sincronización con Supabase (schema v2) ──────
  /// false = pendiente de subir | true = ya sincronizado en la nube.
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  /// UUID asignado por Supabase tras la primera sincronización exitosa.
  /// Permanece null hasta que el registro se suba correctamente.
  TextColumn get supabaseId => text().nullable()();

  // ── Soft delete (schema v3) ───────────────────────────────────
  /// true = el usuario eliminó este gasto localmente y hay que
  /// borrarlo de Supabase en el próximo sync antes de eliminarlo
  /// físicamente de SQLite.  Permanece oculto en todas las queries.
  BoolColumn get pendingDelete =>
      boolean().withDefault(const Constant(false))();

  // ── Categoría (schema v4) ─────────────────────────────────────
  /// UUID de la categoría asignada (FK a categorias.id). Nullable.
  TextColumn get categoriaId => text().nullable()();

  // ── Foto de recibo (schema v5) ─────────────────────────────────
  /// URL de Supabase Storage de la foto del recibo. Nullable.
  TextColumn get fotoUrl => text().nullable()();
}

// ----------------------------------------------------------------
// Tabla de categorías (schema v4)
// ----------------------------------------------------------------
class CategoriasTable extends Table {
  @override
  String get tableName => 'categorias';

  TextColumn get id => text()();
  TextColumn get userId => text().nullable()(); // null = categoría por defecto
  TextColumn get nombre => text()();
  TextColumn get icono => text().nullable()(); // emoji
  TextColumn get color => text().nullable()(); // hex color (#RRGGBB)
  BoolColumn get esDefault =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ----------------------------------------------------------------
// Tabla de presupuestos (schema v4)
// ----------------------------------------------------------------
class PresupuestosTable extends Table {
  @override
  String get tableName => 'presupuestos';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get categoriaId => text().nullable()(); // FK a categorias.id
  RealColumn get montoLimite => real()();
  DateTimeColumn get mes => dateTime()(); // primer día del mes
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [GastosTable, CategoriasTable, PresupuestosTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  /// Migración incremental: solo toca lo que cambió entre versiones.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          // v1 → v2: agregar columnas de sincronización con Supabase
          if (from < 2) {
            await migrator.addColumn(gastosTable, gastosTable.isSynced);
            await migrator.addColumn(gastosTable, gastosTable.supabaseId);
          }
          // v2 → v3: soft delete para sincronización bidireccional segura
          if (from < 3) {
            await migrator.addColumn(
                gastosTable, gastosTable.pendingDelete);
          }
          // v3 → v4: categorías, presupuestos y categoriaId en gastos
          if (from < 4) {
            await migrator.createTable(categoriasTable);
            await migrator.createTable(presupuestosTable);
            await migrator.addColumn(gastosTable, gastosTable.categoriaId);
          }
          // v4 → v5: foto del recibo en gastos
          if (from < 5) {
            await migrator.addColumn(gastosTable, gastosTable.fotoUrl);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'control_gastos.sqlite'));

    // Workaround para Android antiguo
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Directorio temporal para sqlite3
    final cachebase = await getTemporaryDirectory();
    sqlite3.tempDirectory = cachebase.path;

    return NativeDatabase.createInBackground(file);
  });
}
