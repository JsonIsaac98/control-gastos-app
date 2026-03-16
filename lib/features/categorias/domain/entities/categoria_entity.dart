import 'package:flutter/material.dart';

class CategoriaEntity {
  const CategoriaEntity({
    required this.id,
    this.userId,
    required this.nombre,
    this.icono,
    this.color,
    this.esDefault = false,
  });

  final String id;
  final String? userId;
  final String nombre;
  final String? icono;   // emoji
  final String? color;   // hex color (#RRGGBB)
  final bool esDefault;

  /// Parsea el color hexadecimal a un objeto Color de Flutter.
  Color? get colorValue {
    if (color == null) return null;
    final hex = color!.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return null;
  }

  CategoriaEntity copyWith({
    String? id,
    String? userId,
    String? nombre,
    String? icono,
    String? color,
    bool? esDefault,
  }) {
    return CategoriaEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      esDefault: esDefault ?? this.esDefault,
    );
  }

  @override
  String toString() =>
      'CategoriaEntity(id: $id, nombre: $nombre, icono: $icono, color: $color)';
}
