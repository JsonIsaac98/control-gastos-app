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
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<String> categoriaId = GeneratedColumn<String>(
      'categoria_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        pendingDelete,
        categoriaId
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
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
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
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria_id']),
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

  /// UUID de la categoría asignada (FK a categorias.id). Nullable.
  final String? categoriaId;
  const GastosTableData(
      {required this.id,
      required this.descripcion,
      required this.monto,
      required this.tipoPago,
      required this.fecha,
      required this.createdAt,
      required this.isSynced,
      this.supabaseId,
      required this.pendingDelete,
      this.categoriaId});
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
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<String>(categoriaId);
    }
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
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
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
      categoriaId: serializer.fromJson<String?>(json['categoriaId']),
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
      'categoriaId': serializer.toJson<String?>(categoriaId),
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
          bool? pendingDelete,
          Value<String?> categoriaId = const Value.absent()}) =>
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
        categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
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
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
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
          ..write('pendingDelete: $pendingDelete, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, descripcion, monto, tipoPago, fecha,
      createdAt, isSynced, supabaseId, pendingDelete, categoriaId);
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
          other.pendingDelete == this.pendingDelete &&
          other.categoriaId == this.categoriaId);
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
  final Value<String?> categoriaId;
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
    this.categoriaId = const Value.absent(),
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
    this.categoriaId = const Value.absent(),
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
    Expression<String>? categoriaId,
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
      if (categoriaId != null) 'categoria_id': categoriaId,
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
      Value<bool>? pendingDelete,
      Value<String?>? categoriaId}) {
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
      categoriaId: categoriaId ?? this.categoriaId,
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
    if (categoriaId.present) {
      map['categoria_id'] = Variable<String>(categoriaId.value);
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
          ..write('pendingDelete: $pendingDelete, ')
          ..write('categoriaId: $categoriaId')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTableTable extends CategoriasTable
    with TableInfo<$CategoriasTableTable, CategoriasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconoMeta = const VerificationMeta('icono');
  @override
  late final GeneratedColumn<String> icono = GeneratedColumn<String>(
      'icono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _esDefaultMeta =
      const VerificationMeta('esDefault');
  @override
  late final GeneratedColumn<bool> esDefault = GeneratedColumn<bool>(
      'es_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("es_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, nombre, icono, color, esDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('icono')) {
      context.handle(
          _iconoMeta, icono.isAcceptableOrUnknown(data['icono']!, _iconoMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('es_default')) {
      context.handle(_esDefaultMeta,
          esDefault.isAcceptableOrUnknown(data['es_default']!, _esDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriasTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      icono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icono']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      esDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_default'])!,
    );
  }

  @override
  $CategoriasTableTable createAlias(String alias) {
    return $CategoriasTableTable(attachedDatabase, alias);
  }
}

class CategoriasTableData extends DataClass
    implements Insertable<CategoriasTableData> {
  final String id;
  final String? userId;
  final String nombre;
  final String? icono;
  final String? color;
  final bool esDefault;
  const CategoriasTableData(
      {required this.id,
      this.userId,
      required this.nombre,
      this.icono,
      this.color,
      required this.esDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || icono != null) {
      map['icono'] = Variable<String>(icono);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['es_default'] = Variable<bool>(esDefault);
    return map;
  }

  CategoriasTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriasTableCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      nombre: Value(nombre),
      icono:
          icono == null && nullToAbsent ? const Value.absent() : Value(icono),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      esDefault: Value(esDefault),
    );
  }

  factory CategoriasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriasTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      icono: serializer.fromJson<String?>(json['icono']),
      color: serializer.fromJson<String?>(json['color']),
      esDefault: serializer.fromJson<bool>(json['esDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'nombre': serializer.toJson<String>(nombre),
      'icono': serializer.toJson<String?>(icono),
      'color': serializer.toJson<String?>(color),
      'esDefault': serializer.toJson<bool>(esDefault),
    };
  }

  CategoriasTableData copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          String? nombre,
          Value<String?> icono = const Value.absent(),
          Value<String?> color = const Value.absent(),
          bool? esDefault}) =>
      CategoriasTableData(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        nombre: nombre ?? this.nombre,
        icono: icono.present ? icono.value : this.icono,
        color: color.present ? color.value : this.color,
        esDefault: esDefault ?? this.esDefault,
      );
  CategoriasTableData copyWithCompanion(CategoriasTableCompanion data) {
    return CategoriasTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      icono: data.icono.present ? data.icono.value : this.icono,
      color: data.color.present ? data.color.value : this.color,
      esDefault: data.esDefault.present ? data.esDefault.value : this.esDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('icono: $icono, ')
          ..write('color: $color, ')
          ..write('esDefault: $esDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, nombre, icono, color, esDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriasTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nombre == this.nombre &&
          other.icono == this.icono &&
          other.color == this.color &&
          other.esDefault == this.esDefault);
}

class CategoriasTableCompanion extends UpdateCompanion<CategoriasTableData> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> nombre;
  final Value<String?> icono;
  final Value<String?> color;
  final Value<bool> esDefault;
  final Value<int> rowid;
  const CategoriasTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.icono = const Value.absent(),
    this.color = const Value.absent(),
    this.esDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriasTableCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String nombre,
    this.icono = const Value.absent(),
    this.color = const Value.absent(),
    this.esDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombre = Value(nombre);
  static Insertable<CategoriasTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? nombre,
    Expression<String>? icono,
    Expression<String>? color,
    Expression<bool>? esDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nombre != null) 'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
      if (esDefault != null) 'es_default': esDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriasTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<String>? nombre,
      Value<String?>? icono,
      Value<String?>? color,
      Value<bool>? esDefault,
      Value<int>? rowid}) {
    return CategoriasTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      esDefault: esDefault ?? this.esDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (icono.present) {
      map['icono'] = Variable<String>(icono.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (esDefault.present) {
      map['es_default'] = Variable<bool>(esDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('icono: $icono, ')
          ..write('color: $color, ')
          ..write('esDefault: $esDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresupuestosTableTable extends PresupuestosTable
    with TableInfo<$PresupuestosTableTable, PresupuestosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresupuestosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<String> categoriaId = GeneratedColumn<String>(
      'categoria_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _montoLimiteMeta =
      const VerificationMeta('montoLimite');
  @override
  late final GeneratedColumn<double> montoLimite = GeneratedColumn<double>(
      'monto_limite', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  @override
  late final GeneratedColumn<DateTime> mes = GeneratedColumn<DateTime>(
      'mes', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, categoriaId, montoLimite, mes, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presupuestos';
  @override
  VerificationContext validateIntegrity(
      Insertable<PresupuestosTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    }
    if (data.containsKey('monto_limite')) {
      context.handle(
          _montoLimiteMeta,
          montoLimite.isAcceptableOrUnknown(
              data['monto_limite']!, _montoLimiteMeta));
    } else if (isInserting) {
      context.missing(_montoLimiteMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
          _mesMeta, mes.isAcceptableOrUnknown(data['mes']!, _mesMeta));
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresupuestosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresupuestosTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria_id']),
      montoLimite: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_limite'])!,
      mes: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}mes'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $PresupuestosTableTable createAlias(String alias) {
    return $PresupuestosTableTable(attachedDatabase, alias);
  }
}

class PresupuestosTableData extends DataClass
    implements Insertable<PresupuestosTableData> {
  final String id;
  final String userId;
  final String? categoriaId;
  final double montoLimite;
  final DateTime mes;
  final bool isSynced;
  const PresupuestosTableData(
      {required this.id,
      required this.userId,
      this.categoriaId,
      required this.montoLimite,
      required this.mes,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<String>(categoriaId);
    }
    map['monto_limite'] = Variable<double>(montoLimite);
    map['mes'] = Variable<DateTime>(mes);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  PresupuestosTableCompanion toCompanion(bool nullToAbsent) {
    return PresupuestosTableCompanion(
      id: Value(id),
      userId: Value(userId),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      montoLimite: Value(montoLimite),
      mes: Value(mes),
      isSynced: Value(isSynced),
    );
  }

  factory PresupuestosTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresupuestosTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      categoriaId: serializer.fromJson<String?>(json['categoriaId']),
      montoLimite: serializer.fromJson<double>(json['montoLimite']),
      mes: serializer.fromJson<DateTime>(json['mes']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'categoriaId': serializer.toJson<String?>(categoriaId),
      'montoLimite': serializer.toJson<double>(montoLimite),
      'mes': serializer.toJson<DateTime>(mes),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  PresupuestosTableData copyWith(
          {String? id,
          String? userId,
          Value<String?> categoriaId = const Value.absent(),
          double? montoLimite,
          DateTime? mes,
          bool? isSynced}) =>
      PresupuestosTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
        montoLimite: montoLimite ?? this.montoLimite,
        mes: mes ?? this.mes,
        isSynced: isSynced ?? this.isSynced,
      );
  PresupuestosTableData copyWithCompanion(PresupuestosTableCompanion data) {
    return PresupuestosTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
      montoLimite:
          data.montoLimite.present ? data.montoLimite.value : this.montoLimite,
      mes: data.mes.present ? data.mes.value : this.mes,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresupuestosTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('montoLimite: $montoLimite, ')
          ..write('mes: $mes, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, categoriaId, montoLimite, mes, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresupuestosTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.categoriaId == this.categoriaId &&
          other.montoLimite == this.montoLimite &&
          other.mes == this.mes &&
          other.isSynced == this.isSynced);
}

class PresupuestosTableCompanion
    extends UpdateCompanion<PresupuestosTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> categoriaId;
  final Value<double> montoLimite;
  final Value<DateTime> mes;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const PresupuestosTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.montoLimite = const Value.absent(),
    this.mes = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresupuestosTableCompanion.insert({
    required String id,
    required String userId,
    this.categoriaId = const Value.absent(),
    required double montoLimite,
    required DateTime mes,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        montoLimite = Value(montoLimite),
        mes = Value(mes);
  static Insertable<PresupuestosTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? categoriaId,
    Expression<double>? montoLimite,
    Expression<DateTime>? mes,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (montoLimite != null) 'monto_limite': montoLimite,
      if (mes != null) 'mes': mes,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresupuestosTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? categoriaId,
      Value<double>? montoLimite,
      Value<DateTime>? mes,
      Value<bool>? isSynced,
      Value<int>? rowid}) {
    return PresupuestosTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoriaId: categoriaId ?? this.categoriaId,
      montoLimite: montoLimite ?? this.montoLimite,
      mes: mes ?? this.mes,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<String>(categoriaId.value);
    }
    if (montoLimite.present) {
      map['monto_limite'] = Variable<double>(montoLimite.value);
    }
    if (mes.present) {
      map['mes'] = Variable<DateTime>(mes.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresupuestosTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('montoLimite: $montoLimite, ')
          ..write('mes: $mes, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GastosTableTable gastosTable = $GastosTableTable(this);
  late final $CategoriasTableTable categoriasTable =
      $CategoriasTableTable(this);
  late final $PresupuestosTableTable presupuestosTable =
      $PresupuestosTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [gastosTable, categoriasTable, presupuestosTable];
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
  Value<String?> categoriaId,
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
  Value<String?> categoriaId,
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

  ColumnFilters<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => column);
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
            Value<String?> categoriaId = const Value.absent(),
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
            categoriaId: categoriaId,
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
            Value<String?> categoriaId = const Value.absent(),
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
            categoriaId: categoriaId,
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
typedef $$CategoriasTableTableCreateCompanionBuilder = CategoriasTableCompanion
    Function({
  required String id,
  Value<String?> userId,
  required String nombre,
  Value<String?> icono,
  Value<String?> color,
  Value<bool> esDefault,
  Value<int> rowid,
});
typedef $$CategoriasTableTableUpdateCompanionBuilder = CategoriasTableCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<String> nombre,
  Value<String?> icono,
  Value<String?> color,
  Value<bool> esDefault,
  Value<int> rowid,
});

class $$CategoriasTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTableTable> {
  $$CategoriasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icono => $composableBuilder(
      column: $table.icono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esDefault => $composableBuilder(
      column: $table.esDefault, builder: (column) => ColumnFilters(column));
}

class $$CategoriasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTableTable> {
  $$CategoriasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icono => $composableBuilder(
      column: $table.icono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esDefault => $composableBuilder(
      column: $table.esDefault, builder: (column) => ColumnOrderings(column));
}

class $$CategoriasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTableTable> {
  $$CategoriasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get icono =>
      $composableBuilder(column: $table.icono, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get esDefault =>
      $composableBuilder(column: $table.esDefault, builder: (column) => column);
}

class $$CategoriasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriasTableTable,
    CategoriasTableData,
    $$CategoriasTableTableFilterComposer,
    $$CategoriasTableTableOrderingComposer,
    $$CategoriasTableTableAnnotationComposer,
    $$CategoriasTableTableCreateCompanionBuilder,
    $$CategoriasTableTableUpdateCompanionBuilder,
    (
      CategoriasTableData,
      BaseReferences<_$AppDatabase, $CategoriasTableTable, CategoriasTableData>
    ),
    CategoriasTableData,
    PrefetchHooks Function()> {
  $$CategoriasTableTableTableManager(
      _$AppDatabase db, $CategoriasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> icono = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> esDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriasTableCompanion(
            id: id,
            userId: userId,
            nombre: nombre,
            icono: icono,
            color: color,
            esDefault: esDefault,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required String nombre,
            Value<String?> icono = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> esDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriasTableCompanion.insert(
            id: id,
            userId: userId,
            nombre: nombre,
            icono: icono,
            color: color,
            esDefault: esDefault,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriasTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriasTableTable,
    CategoriasTableData,
    $$CategoriasTableTableFilterComposer,
    $$CategoriasTableTableOrderingComposer,
    $$CategoriasTableTableAnnotationComposer,
    $$CategoriasTableTableCreateCompanionBuilder,
    $$CategoriasTableTableUpdateCompanionBuilder,
    (
      CategoriasTableData,
      BaseReferences<_$AppDatabase, $CategoriasTableTable, CategoriasTableData>
    ),
    CategoriasTableData,
    PrefetchHooks Function()>;
typedef $$PresupuestosTableTableCreateCompanionBuilder
    = PresupuestosTableCompanion Function({
  required String id,
  required String userId,
  Value<String?> categoriaId,
  required double montoLimite,
  required DateTime mes,
  Value<bool> isSynced,
  Value<int> rowid,
});
typedef $$PresupuestosTableTableUpdateCompanionBuilder
    = PresupuestosTableCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> categoriaId,
  Value<double> montoLimite,
  Value<DateTime> mes,
  Value<bool> isSynced,
  Value<int> rowid,
});

class $$PresupuestosTableTableFilterComposer
    extends Composer<_$AppDatabase, $PresupuestosTableTable> {
  $$PresupuestosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoLimite => $composableBuilder(
      column: $table.montoLimite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get mes => $composableBuilder(
      column: $table.mes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$PresupuestosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PresupuestosTableTable> {
  $$PresupuestosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoLimite => $composableBuilder(
      column: $table.montoLimite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get mes => $composableBuilder(
      column: $table.mes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$PresupuestosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresupuestosTableTable> {
  $$PresupuestosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get categoriaId => $composableBuilder(
      column: $table.categoriaId, builder: (column) => column);

  GeneratedColumn<double> get montoLimite => $composableBuilder(
      column: $table.montoLimite, builder: (column) => column);

  GeneratedColumn<DateTime> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$PresupuestosTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PresupuestosTableTable,
    PresupuestosTableData,
    $$PresupuestosTableTableFilterComposer,
    $$PresupuestosTableTableOrderingComposer,
    $$PresupuestosTableTableAnnotationComposer,
    $$PresupuestosTableTableCreateCompanionBuilder,
    $$PresupuestosTableTableUpdateCompanionBuilder,
    (
      PresupuestosTableData,
      BaseReferences<_$AppDatabase, $PresupuestosTableTable,
          PresupuestosTableData>
    ),
    PresupuestosTableData,
    PrefetchHooks Function()> {
  $$PresupuestosTableTableTableManager(
      _$AppDatabase db, $PresupuestosTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresupuestosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresupuestosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresupuestosTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> categoriaId = const Value.absent(),
            Value<double> montoLimite = const Value.absent(),
            Value<DateTime> mes = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PresupuestosTableCompanion(
            id: id,
            userId: userId,
            categoriaId: categoriaId,
            montoLimite: montoLimite,
            mes: mes,
            isSynced: isSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> categoriaId = const Value.absent(),
            required double montoLimite,
            required DateTime mes,
            Value<bool> isSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PresupuestosTableCompanion.insert(
            id: id,
            userId: userId,
            categoriaId: categoriaId,
            montoLimite: montoLimite,
            mes: mes,
            isSynced: isSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PresupuestosTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PresupuestosTableTable,
    PresupuestosTableData,
    $$PresupuestosTableTableFilterComposer,
    $$PresupuestosTableTableOrderingComposer,
    $$PresupuestosTableTableAnnotationComposer,
    $$PresupuestosTableTableCreateCompanionBuilder,
    $$PresupuestosTableTableUpdateCompanionBuilder,
    (
      PresupuestosTableData,
      BaseReferences<_$AppDatabase, $PresupuestosTableTable,
          PresupuestosTableData>
    ),
    PresupuestosTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GastosTableTableTableManager get gastosTable =>
      $$GastosTableTableTableManager(_db, _db.gastosTable);
  $$CategoriasTableTableTableManager get categoriasTable =>
      $$CategoriasTableTableTableManager(_db, _db.categoriasTable);
  $$PresupuestosTableTableTableManager get presupuestosTable =>
      $$PresupuestosTableTableTableManager(_db, _db.presupuestosTable);
}
