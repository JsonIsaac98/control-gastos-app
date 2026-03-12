// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GastosTableTable extends GastosTable
    with TableInfo<$GastosTableTable, GastosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
      'monto', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tipoPagoMeta =
      const VerificationMeta('tipoPago');
  @override
  late final GeneratedColumn<String> tipoPago = GeneratedColumn<String>(
      'tipo_pago', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _supabaseIdMeta =
      const VerificationMeta('supabaseId');
  @override
  late final GeneratedColumn<String> supabaseId = GeneratedColumn<String>(
      'supabase_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingDeleteMeta =
      const VerificationMeta('pendingDelete');
  @override
  late final GeneratedColumn<bool> pendingDelete = GeneratedColumn<bool>(
      'pending_delete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_delete" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        descripcion,
        monto,
        tipoPago,
        fecha,
        createdAt,
        isSynced,
        supabaseId,
        pendingDelete
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(Insertable<GastosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('tipo_pago')) {
      context.handle(_tipoPagoMeta,
          tipoPago.isAcceptableOrUnknown(data['tipo_pago']!, _tipoPagoMeta));
    } else if (isInserting) {
      context.missing(_tipoPagoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('supabase_id')) {
      context.handle(
          _supabaseIdMeta,
          supabaseId.isAcceptableOrUnknown(
              data['supabase_id']!, _supabaseIdMeta));
    }
    if (data.containsKey('pending_delete')) {
      context.handle(
          _pendingDeleteMeta,
          pendingDelete.isAcceptableOrUnknown(
              data['pending_delete']!, _pendingDeleteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GastosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GastosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion'])!,
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto'])!,
      tipoPago: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_pago'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      supabaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supabase_id']),
      pendingDelete: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_delete'])!,
    );
  }

  @override
  $GastosTableTable createAlias(String alias) {
    return $GastosTableTable(attachedDatabase, alias);
  }
}

class GastosTableData extends DataClass implements Insertable<GastosTableData> {
  final int id;
  final String descripcion;
  final double monto;
  final String tipoPago;
  final DateTime fecha;
  final DateTime createdAt;

  /// false = pendiente de subir | true = ya sincronizado en la nube.
  final bool isSynced;

  /// UUID asignado por Supabase tras la primera sincronización exitosa.
  /// Permanece null hasta que el registro se suba correctamente.
  final String? supabaseId;

  /// true = el usuario eliminó este gasto localmente y hay que
  /// borrarlo de Supabase en el próximo sync antes de eliminarlo
  /// físicamente de SQLite.  Permanece oculto en todas las queries.
  final bool pendingDelete;
  const GastosTableData(
      {required this.id,
      required this.descripcion,
      required this.monto,
      required this.tipoPago,
      required this.fecha,
      required this.createdAt,
      required this.isSynced,
      this.supabaseId,
      required this.pendingDelete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descripcion'] = Variable<String>(descripcion);
    map['monto'] = Variable<double>(monto);
    map['tipo_pago'] = Variable<String>(tipoPago);
    map['fecha'] = Variable<DateTime>(fecha);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || supabaseId != null) {
      map['supabase_id'] = Variable<String>(supabaseId);
    }
    map['pending_delete'] = Variable<bool>(pendingDelete);
    return map;
  }

  GastosTableCompanion toCompanion(bool nullToAbsent) {
    return GastosTableCompanion(
      id: Value(id),
      descripcion: Value(descripcion),
      monto: Value(monto),
      tipoPago: Value(tipoPago),
      fecha: Value(fecha),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      supabaseId: supabaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supabaseId),
      pendingDelete: Value(pendingDelete),
    );
  }

  factory GastosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GastosTableData(
      id: serializer.fromJson<int>(json['id']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      monto: serializer.fromJson<double>(json['monto']),
      tipoPago: serializer.fromJson<String>(json['tipoPago']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      supabaseId: serializer.fromJson<String?>(json['supabaseId']),
      pendingDelete: serializer.fromJson<bool>(json['pendingDelete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descripcion': serializer.toJson<String>(descripcion),
      'monto': serializer.toJson<double>(monto),
      'tipoPago': serializer.toJson<String>(tipoPago),
      'fecha': serializer.toJson<DateTime>(fecha),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'supabaseId': serializer.toJson<String?>(supabaseId),
      'pendingDelete': serializer.toJson<bool>(pendingDelete),
    };
  }

  GastosTableData copyWith(
          {int? id,
          String? descripcion,
          double? monto,
          String? tipoPago,
          DateTime? fecha,
          DateTime? createdAt,
          bool? isSynced,
          Value<String?> supabaseId = const Value.absent(),
          bool? pendingDelete}) =>
      GastosTableData(
        id: id ?? this.id,
        descripcion: descripcion ?? this.descripcion,
        monto: monto ?? this.monto,
        tipoPago: tipoPago ?? this.tipoPago,
        fecha: fecha ?? this.fecha,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        supabaseId: supabaseId.present ? supabaseId.value : this.supabaseId,
        pendingDelete: pendingDelete ?? this.pendingDelete,
      );
  GastosTableData copyWithCompanion(GastosTableCompanion data) {
    return GastosTableData(
      id: data.id.present ? data.id.value : this.id,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      monto: data.monto.present ? data.monto.value : this.monto,
      tipoPago: data.tipoPago.present ? data.tipoPago.value : this.tipoPago,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      supabaseId:
          data.supabaseId.present ? data.supabaseId.value : this.supabaseId,
      pendingDelete: data.pendingDelete.present
          ? data.pendingDelete.value
          : this.pendingDelete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GastosTableData(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('monto: $monto, ')
          ..write('tipoPago: $tipoPago, ')
          ..write('fecha: $fecha, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('pendingDelete: $pendingDelete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, descripcion, monto, tipoPago, fecha,
      createdAt, isSynced, supabaseId, pendingDelete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GastosTableData &&
          other.id == this.id &&
          other.descripcion == this.descripcion &&
          other.monto == this.monto &&
          other.tipoPago == this.tipoPago &&
          other.fecha == this.fecha &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.supabaseId == this.supabaseId &&
          other.pendingDelete == this.pendingDelete);
}

class GastosTableCompanion extends UpdateCompanion<GastosTableData> {
  final Value<int> id;
  final Value<String> descripcion;
  final Value<double> monto;
  final Value<String> tipoPago;
  final Value<DateTime> fecha;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<String?> supabaseId;
  final Value<bool> pendingDelete;
  const GastosTableCompanion({
    this.id = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.monto = const Value.absent(),
    this.tipoPago = const Value.absent(),
    this.fecha = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.pendingDelete = const Value.absent(),
  });
  GastosTableCompanion.insert({
    this.id = const Value.absent(),
    required String descripcion,
    required double monto,
    required String tipoPago,
    required DateTime fecha,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.supabaseId = const Value.absent(),
    this.pendingDelete = const Value.absent(),
  })  : descripcion = Value(descripcion),
        monto = Value(monto),
        tipoPago = Value(tipoPago),
        fecha = Value(fecha);
  static Insertable<GastosTableData> custom({
    Expression<int>? id,
    Expression<String>? descripcion,
    Expression<double>? monto,
    Expression<String>? tipoPago,
    Expression<DateTime>? fecha,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? supabaseId,
    Expression<bool>? pendingDelete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descripcion != null) 'descripcion': descripcion,
      if (monto != null) 'monto': monto,
      if (tipoPago != null) 'tipo_pago': tipoPago,
      if (fecha != null) 'fecha': fecha,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (supabaseId != null) 'supabase_id': supabaseId,
      if (pendingDelete != null) 'pending_delete': pendingDelete,
    });
  }

  GastosTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? descripcion,
      Value<double>? monto,
      Value<String>? tipoPago,
      Value<DateTime>? fecha,
      Value<DateTime>? createdAt,
      Value<bool>? isSynced,
      Value<String?>? supabaseId,
      Value<bool>? pendingDelete}) {
    return GastosTableCompanion(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      tipoPago: tipoPago ?? this.tipoPago,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      supabaseId: supabaseId ?? this.supabaseId,
      pendingDelete: pendingDelete ?? this.pendingDelete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (tipoPago.present) {
      map['tipo_pago'] = Variable<String>(tipoPago.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (supabaseId.present) {
      map['supabase_id'] = Variable<String>(supabaseId.value);
    }
    if (pendingDelete.present) {
      map['pending_delete'] = Variable<bool>(pendingDelete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosTableCompanion(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('monto: $monto, ')
          ..write('tipoPago: $tipoPago, ')
          ..write('fecha: $fecha, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('supabaseId: $supabaseId, ')
          ..write('pendingDelete: $pendingDelete')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GastosTableTable gastosTable = $GastosTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [gastosTable];
}

typedef $$GastosTableTableCreateCompanionBuilder = GastosTableCompanion
    Function({
  Value<int> id,
  required String descripcion,
  required double monto,
  required String tipoPago,
  required DateTime fecha,
  Value<DateTime> createdAt,
  Value<bool> isSynced,
  Value<String?> supabaseId,
  Value<bool> pendingDelete,
});
typedef $$GastosTableTableUpdateCompanionBuilder = GastosTableCompanion
    Function({
  Value<int> id,
  Value<String> descripcion,
  Value<double> monto,
  Value<String> tipoPago,
  Value<DateTime> fecha,
  Value<DateTime> createdAt,
  Value<bool> isSynced,
  Value<String?> supabaseId,
  Value<bool> pendingDelete,
});

class $$GastosTableTableFilterComposer
    extends Composer<_$AppDatabase, $GastosTableTable> {
  $$GastosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoPago => $composableBuilder(
      column: $table.tipoPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingDelete => $composableBuilder(
      column: $table.pendingDelete, builder: (column) => ColumnFilters(column));
}

class $$GastosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GastosTableTable> {
  $$GastosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoPago => $composableBuilder(
      column: $table.tipoPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingDelete => $composableBuilder(
      column: $table.pendingDelete,
      builder: (column) => ColumnOrderings(column));
}

class $$GastosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GastosTableTable> {
  $$GastosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get tipoPago =>
      $composableBuilder(column: $table.tipoPago, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get supabaseId => $composableBuilder(
      column: $table.supabaseId, builder: (column) => column);

  GeneratedColumn<bool> get pendingDelete => $composableBuilder(
      column: $table.pendingDelete, builder: (column) => column);
}

class $$GastosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GastosTableTable,
    GastosTableData,
    $$GastosTableTableFilterComposer,
    $$GastosTableTableOrderingComposer,
    $$GastosTableTableAnnotationComposer,
    $$GastosTableTableCreateCompanionBuilder,
    $$GastosTableTableUpdateCompanionBuilder,
    (
      GastosTableData,
      BaseReferences<_$AppDatabase, $GastosTableTable, GastosTableData>
    ),
    GastosTableData,
    PrefetchHooks Function()> {
  $$GastosTableTableTableManager(_$AppDatabase db, $GastosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> descripcion = const Value.absent(),
            Value<double> monto = const Value.absent(),
            Value<String> tipoPago = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<bool> pendingDelete = const Value.absent(),
          }) =>
              GastosTableCompanion(
            id: id,
            descripcion: descripcion,
            monto: monto,
            tipoPago: tipoPago,
            fecha: fecha,
            createdAt: createdAt,
            isSynced: isSynced,
            supabaseId: supabaseId,
            pendingDelete: pendingDelete,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String descripcion,
            required double monto,
            required String tipoPago,
            required DateTime fecha,
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<String?> supabaseId = const Value.absent(),
            Value<bool> pendingDelete = const Value.absent(),
          }) =>
              GastosTableCompanion.insert(
            id: id,
            descripcion: descripcion,
            monto: monto,
            tipoPago: tipoPago,
            fecha: fecha,
            createdAt: createdAt,
            isSynced: isSynced,
            supabaseId: supabaseId,
            pendingDelete: pendingDelete,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GastosTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GastosTableTable,
    GastosTableData,
    $$GastosTableTableFilterComposer,
    $$GastosTableTableOrderingComposer,
    $$GastosTableTableAnnotationComposer,
    $$GastosTableTableCreateCompanionBuilder,
    $$GastosTableTableUpdateCompanionBuilder,
    (
      GastosTableData,
      BaseReferences<_$AppDatabase, $GastosTableTable, GastosTableData>
    ),
    GastosTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GastosTableTableTableManager get gastosTable =>
      $$GastosTableTableTableManager(_db, _db.gastosTable);
}
