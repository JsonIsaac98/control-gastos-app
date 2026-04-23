class TarjetaEntity {
  const TarjetaEntity({
    required this.id,
    required this.nombre,
    required this.diaCorte,
    this.color,
    this.isDefault = false,
    this.orden = 0,
  });

  final String id;
  final String nombre;
  final int diaCorte;
  final String? color; // hex, e.g. "#1E40AF"
  final bool isDefault;
  final int orden;

  TarjetaEntity copyWith({
    String? id,
    String? nombre,
    int? diaCorte,
    String? color,
    bool? isDefault,
    int? orden,
  }) {
    return TarjetaEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      diaCorte: diaCorte ?? this.diaCorte,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      orden: orden ?? this.orden,
    );
  }

  static const List<String> coloresPreset = [
    '#1E40AF', // Azul
    '#065F46', // Verde
    '#991B1B', // Rojo
    '#6B21A8', // Morado
    '#B45309', // Naranja
    '#374151', // Gris
    '#0E7490', // Cyan
    '#9D174D', // Rosa
  ];
}
