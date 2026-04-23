class CuotaProgramadaEntity {
  const CuotaProgramadaEntity({
    this.id,
    required this.gastoOrigenId,
    this.gastoOrigenSupabaseId,
    required this.descripcion,
    required this.numeroCuota,
    required this.totalCuotas,
    required this.monto,
    required this.fechaVencimiento,
    this.isPagado = false,
    this.fechaPagado,
    this.gastoRegistradoId,
    this.isSynced = false,
    this.supabaseId,
    this.tarjetaId,
  });

  final int? id;
  final int gastoOrigenId;
  final String? gastoOrigenSupabaseId;
  final String descripcion;
  final int numeroCuota;
  final int totalCuotas;
  final double monto;
  final DateTime fechaVencimiento;
  final bool isPagado;
  final DateTime? fechaPagado;
  /// ID local del gasto registrado como pago de esta cuota.
  final int? gastoRegistradoId;
  final bool isSynced;
  final String? supabaseId;
  /// ID de la tarjeta de crédito asociada.
  final String? tarjetaId;

  /// true si la cuota vence hoy o antes y no ha sido pagada.
  bool get isVencida =>
      !isPagado && fechaVencimiento.isBefore(DateTime.now());

  /// true si la cuota vence en los próximos 7 días.
  bool get isProxima =>
      !isPagado &&
      !isVencida &&
      fechaVencimiento
          .isBefore(DateTime.now().add(const Duration(days: 7)));

  CuotaProgramadaEntity copyWith({
    int? id,
    int? gastoOrigenId,
    String? gastoOrigenSupabaseId,
    String? descripcion,
    int? numeroCuota,
    int? totalCuotas,
    double? monto,
    DateTime? fechaVencimiento,
    bool? isPagado,
    DateTime? fechaPagado,
    int? gastoRegistradoId,
    bool? isSynced,
    String? supabaseId,
    String? tarjetaId,
  }) {
    return CuotaProgramadaEntity(
      id: id ?? this.id,
      gastoOrigenId: gastoOrigenId ?? this.gastoOrigenId,
      gastoOrigenSupabaseId:
          gastoOrigenSupabaseId ?? this.gastoOrigenSupabaseId,
      descripcion: descripcion ?? this.descripcion,
      numeroCuota: numeroCuota ?? this.numeroCuota,
      totalCuotas: totalCuotas ?? this.totalCuotas,
      monto: monto ?? this.monto,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      isPagado: isPagado ?? this.isPagado,
      fechaPagado: fechaPagado ?? this.fechaPagado,
      gastoRegistradoId: gastoRegistradoId ?? this.gastoRegistradoId,
      isSynced: isSynced ?? this.isSynced,
      supabaseId: supabaseId ?? this.supabaseId,
      tarjetaId: tarjetaId ?? this.tarjetaId,
    );
  }
}
