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

  // ── Tarjeta de crédito usada (schema v8) ──────────────────────
  /// FK a tarjetas_credito.id. Null si no es pago con tarjeta o no especificada.
  TextColumn get tarjetaId => text().nullable()();

  // ── Cuotas de tarjeta de crédito (schema v6) ──────────────────
  /// true = compra financiada en cuotas (solo aplica a tarjeta_credito).
  BoolColumn get esCuota =>
      boolean().withDefault(const Constant(false))();
  /// Cantidad de cuotas (ej: 3, 6, 12). Null si no es cuota.
  IntColumn get numeroCuotas => integer().nullable()();
  /// Frecuencia de pago: 'mensual' | 'quincenal' | 'semanal'. Null si no es cuota.
  TextColumn get frecuenciaCuotas => text().nullable()();
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

// ----------------------------------------------------------------
// Tabla de tarjetas de crédito (schema v8)
// ----------------------------------------------------------------
class TarjetasCreditoTable extends Table {
  @override
  String get tableName => 'tarjetas_credito';

  TextColumn get id => text()();
  TextColumn get nombre => text()(); // "TC PROMERICA"
  IntColumn get diaCorte => integer()(); // 1-28
  TextColumn get color => text().nullable()(); // hex color para la UI
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  IntColumn get orden => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ----------------------------------------------------------------
// Tabla de cuotas programadas (schema v7)
// ----------------------------------------------------------------
class CuotasProgramadasTable extends Table {
  @override
  String get tableName => 'cuotas_programadas';

  IntColumn get id => integer().autoIncrement()();
  /// FK al gasto que originó la compra a cuotas.
  IntColumn get gastoOrigenId => integer()();
  /// UUID de Supabase del gasto origen (para sync).
  TextColumn get gastoOrigenSupabaseId => text().nullable()();
  /// FK a la tarjeta de crédito usada (schema v8).
  TextColumn get tarjetaId => text().nullable()();
  /// Descripción cacheada del gasto origen.
  TextColumn get descripcion => text()();
  /// Número de esta cuota (1-based).
  IntColumn get numeroCuota => integer()();
  /// Total de cuotas del plan.
  IntColumn get totalCuotas => integer()();
  /// Monto por cuota (total / totalCuotas).
  RealColumn get monto => real()();
  /// Fecha estimada de cargo en tarjeta (día de corte del mes).
  DateTimeColumn get fechaVencimiento => dateTime()();
  BoolColumn get isPagado =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaPagado => dateTime().nullable()();
  /// FK al gasto registrado para esta cuota cuando se paga.
  IntColumn get gastoRegistradoId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

@DriftDatabase(tables: [GastosTable, CategoriasTable, PresupuestosTable, CuotasProgramadasTable, TarjetasCreditoTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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
          // v5 → v6: cuotas de tarjeta de crédito
          if (from < 6) {
            await migrator.addColumn(gastosTable, gastosTable.esCuota);
            await migrator.addColumn(gastosTable, gastosTable.numeroCuotas);
            await migrator.addColumn(gastosTable, gastosTable.frecuenciaCuotas);
          }
          // v6 → v7: tabla de seguimiento de cuotas programadas
          if (from < 7) {
            await migrator.createTable(cuotasProgramadasTable);
          }
          // v7 → v8: tarjetas de crédito + tarjetaId en gastos y cuotas
          if (from < 8) {
            await migrator.createTable(tarjetasCreditoTable);
            await migrator.addColumn(gastosTable, gastosTable.tarjetaId);
            await migrator.addColumn(
                cuotasProgramadasTable, cuotasProgramadasTable.tarjetaId);
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
