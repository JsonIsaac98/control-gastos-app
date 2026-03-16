class PresupuestoEntity {
  const PresupuestoEntity({
    required this.id,
    required this.userId,
    this.categoriaId,
    required this.montoLimite,
    required this.mes,
    this.isSynced = false,
  });

  final String id;
  final String userId;
  final String? categoriaId;
  final double montoLimite;
  final DateTime mes;
  final bool isSynced;

  PresupuestoEntity copyWith({
    String? id,
    String? userId,
    String? categoriaId,
    double? montoLimite,
    DateTime? mes,
    bool? isSynced,
  }) {
    return PresupuestoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoriaId: categoriaId ?? this.categoriaId,
      montoLimite: montoLimite ?? this.montoLimite,
      mes: mes ?? this.mes,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() =>
      'PresupuestoEntity(id: $id, categoriaId: $categoriaId, '
      'montoLimite: $montoLimite, mes: $mes)';
}
