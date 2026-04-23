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
    // Foto de recibo (schema v5)
    this.fotoUrl,
    // Cuotas de tarjeta de crédito (schema v6)
    this.esCuota = false,
    this.numeroCuotas,
    this.frecuenciaCuotas,
    // Tarjeta de crédito seleccionada (schema v8)
    this.tarjetaId,
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
  /// URL de Supabase Storage de la foto del recibo. Null si no tiene foto.
  final String? fotoUrl;
  /// true = compra a cuotas (solo tarjeta_credito).
  final bool esCuota;
  /// Número de cuotas (ej: 3, 6, 12). Null si no es cuota.
  final int? numeroCuotas;
  /// Frecuencia de pago: 'mensual' | 'quincenal' | 'semanal'. Null si no es cuota.
  final String? frecuenciaCuotas;
  /// ID de la tarjeta de crédito usada. Null si no es tarjeta o no especificada.
  final String? tarjetaId;

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
    String? fotoUrl,
    bool? esCuota,
    int? numeroCuotas,
    String? frecuenciaCuotas,
    String? tarjetaId,
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
      fotoUrl: fotoUrl ?? this.fotoUrl,
      esCuota: esCuota ?? this.esCuota,
      numeroCuotas: numeroCuotas ?? this.numeroCuotas,
      frecuenciaCuotas: frecuenciaCuotas ?? this.frecuenciaCuotas,
      tarjetaId: tarjetaId ?? this.tarjetaId,
    );
  }

  @override
  String toString() =>
      'GastoEntity(id: $id, descripcion: $descripcion, monto: $monto, '
      'tipoPago: ${tipoPago.label}, fecha: $fecha, '
      'isSynced: $isSynced, supabaseId: $supabaseId, categoriaId: $categoriaId, '
      'fotoUrl: $fotoUrl, esCuota: $esCuota, numeroCuotas: $numeroCuotas, '
      'frecuenciaCuotas: $frecuenciaCuotas)';
}
