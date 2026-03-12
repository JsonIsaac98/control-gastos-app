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
}

@DriftDatabase(tables: [GastosTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  /// Migración incremental: solo toca lo que cambió entre versiones.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          // v1 → v2: agregar columnas de sincronización con Supabase
          if (from < 2) {
            await migrator.addColumn(gastosTable, gastosTable.isSynced);
            await migrator.addColumn(gastosTable, gastosTable.supabaseId);
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
