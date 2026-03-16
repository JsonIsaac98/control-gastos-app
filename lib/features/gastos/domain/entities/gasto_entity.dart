enum TipoPago {
  efectivo('efectivo', 'Efectivo'),
  tarjetaCredito('tarjeta_credito', 'Tarjeta de Crédito'),
  transferencia('transferencia', 'Transferencia');

  const TipoPago(this.valor, this.label);

  final String valor;
  final String label;

  static TipoPago fromValor(String valor) {
    return TipoPago.values.firstWhere(
      (t) => t.valor == valor,
      orElse: () => TipoPago.efectivo,
    );
  }
}

class GastoEntity {
  const GastoEntity({
    this.id,
    required this.descripcion,
    required this.monto,
    required this.tipoPago,
    required this.fecha,
    this.createdAt,
    // Campos de sincronización con Supabase
    this.isSynced = false,
    this.supabaseId,
    // Categoría (schema v4)
    this.categoriaId,
  });

  final int? id;
  final String descripcion;
  final double monto;
  final TipoPago tipoPago;
  final DateTime fecha;
  final DateTime? createdAt;
  /// true = sincronizado en Supabase | false = pendiente de subir.
  final bool isSynced;
  /// UUID asignado por Supabase. Null hasta la primera sincronización.
  final String? supabaseId;
  /// UUID de la categoría asignada. Null si no tiene categoría.
  final String? categoriaId;

  GastoEntity copyWith({
    int? id,
    String? descripcion,
    double? monto,
    TipoPago? tipoPago,
    DateTime? fecha,
    DateTime? createdAt,
    bool? isSynced,
    String? supabaseId,
    String? categoriaId,
  }) {
    return GastoEntity(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      tipoPago: tipoPago ?? this.tipoPago,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      supabaseId: supabaseId ?? this.supabaseId,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  @override
  String toString() =>
      'GastoEntity(id: $id, descripcion: $descripcion, monto: $monto, '
      'tipoPago: ${tipoPago.label}, fecha: $fecha, '
      'isSynced: $isSynced, supabaseId: $supabaseId, categoriaId: $categoriaId)';
}
